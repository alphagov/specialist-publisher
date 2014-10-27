require "securerandom"

class ManualDocumentBuilder
  def initialize(dependencies)
    @factory_factory = dependencies.fetch(:factory_factory)
  end

  def call(manual, attrs)
    document = @factory_factory
      .call(manual)
      .call(SecureRandom.uuid, [])

    document.update(attrs.reverse_merge(defaults))

    document
  end

private

  def defaults
    {
      document_type: "manual",
      change_note: "New section added.",
    }
  end
end
