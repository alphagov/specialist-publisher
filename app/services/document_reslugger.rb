class DocumentReslugger
  Report = Struct.new(:published, :drafted, :skipped, :failed) do
    def to_s
      {
        "Published" => published,
        "Drafted" => drafted,
        "Skipped" => skipped,
        "Failed" => failed,
      }.map { |label, paths| ["#{label} #{paths.size}:", *paths].join("\n") }.join("\n")
    end
  end

  def initialize(document_type, finder_base_path)
    @document_type = document_type
    @finder_base_path = finder_base_path
    @published = []
    @drafted = []
    @skipped = []
    @failed = []
  end

  def reslug_all
    klass.find_each do |document|
      reslug(document)
    end

    Report.new(@published, @drafted, @skipped, @failed)
  end

private

  def klass
    @klass ||= begin
      Rails.application.eager_load!
      Document.subclasses.find { |subclass| subclass.document_type == @document_type } ||
        raise(ArgumentError, "Unknown document_type: #{@document_type}")
    end
  end

  # Reslugs a single document according to its state:
  #   - already under the finder's base_path -> skipped
  #   - unpublished -> skipped
  #   - published -> moved and re-published, so the old path redirects
  #   - draft (incl. published-with-new-draft) -> moved, kept in draft
  #   - a failed save/publish or unexpected error -> recorded as a failure
  def reslug(document)
    if should_reslug?(document)
      new_base_path = target_base_path(document)
      was_reslugged = move_to_new_base_path(document, new_base_path)

      if was_reslugged
        outcome_for(document) << new_base_path
      else
        record_failure(document)
      end
    else
      skip(document)
    end
  rescue StandardError => e
    @failed << "#{document.content_id} (#{document.locale}) - #{e.message}"
  end

  def should_reslug?(document)
    !already_reslugged?(document) && (document.published? || document.draft?)
  end

  def already_reslugged?(document)
    target = target_base_path(document)
    target.nil? || target == document.base_path
  end

  def move_to_new_base_path(document, new_base_path)
    document.base_path = new_base_path
    document.update_type = "minor"
    document.save && (document.draft? || document.publish)
  end

  def outcome_for(document)
    document.published? ? @published : @drafted
  end

  def target_base_path(document)
    return unless document.base_path

    "#{@finder_base_path}/#{File.basename(document.base_path)}"
  end

  def skip(document)
    @skipped << "#{document.base_path} (#{document.publication_state})"
  end

  def record_failure(document)
    @failed << "#{document.content_id} (#{document.locale}) - #{document.errors.full_messages.join(', ')}"
  end
end
