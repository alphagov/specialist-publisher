require "tag_fetcher"

class PublishManualService
  def initialize(dependencies)
    @manual_id = dependencies.fetch(:manual_id)
    @manual_repository = dependencies.fetch(:manual_repository)
    @listeners = dependencies.fetch(:listeners)
    @version_number = dependencies.fetch(:version_number)
  end

  def call
    if versions_match?
      update_manual_with_tags
      publish
      notify_listeners
      persist
    else
      raise VersionMismatchError.new(
        %Q(The manual with id '#{manual.id}' could not be published due to a version mismatch.
          The version to publish was '#{version_number}' but the current version was '#{manual.version_number}')
      )
    end

    manual
  end

private

  attr_reader(
    :manual_id,
    :manual_repository,
    :listeners,
    :version_number,
  )

  def versions_match?
    version_number == manual.version_number
  end

  def publish
    manual.publish
  end

  def tags
    TagFetcher.new(manual).tags.map { |t|
      {
        type: t.details.type,
        slug: t.slug,
      }
    }
  end

  def update_manual_with_tags
    manual.update({tags: tags})
  end

  def persist
    manual_repository.store(manual)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(manual)
    end
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  class VersionMismatchError < StandardError
  end
end
