class ManualLinksPresenter
  def initialize(manual)
    @manual = manual
  end

  def to_json
    {
      content_id: manual.content_id,
      links: {
        organisations: manual.organisation_content_ids
      },
    }
  end

private

  attr_reader :manual
end
