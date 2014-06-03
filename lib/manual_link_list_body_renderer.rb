class ManualLinkListBodyRenderer

  def initialize(manual)
    @manual = manual
  end

  def id
    manual.id
  end

  def body
    manual.documents.map { |d|
      "* [#{d.title}](/#{d.slug})"
   }.join("\n") + "\n"
  end

  def attributes
    {
      id: manual.id,
      slug: manual.slug,
      title: manual.title,
      body: body,
      summary: manual.summary,
    }
  end

  private

  attr_reader :manual

end
