class RemovePublishedStyleGuideSection < Mongoid::Migration
  MANUAL_ID = "6d1e2424-f2dd-4db1-930e-e3c1a0cae5c3"
  MANUAL_DOCUMENT_ID = "985ea106-ba31-48d6-9d9b-3086e42b712e"

  class ManualWithoutSection < SimpleDelegator
    def initialize(manual, target_for_removal)
      @target_for_removal = target_for_removal
      super(manual)
    end

    def documents
      __getobj__.documents.reject { |doc|
        doc.id == target_for_removal
      }
    end

  private
    attr_reader :target_for_removal
  end

  def self.up
    manual = ManualWithoutSection.new(
      repository.fetch(MANUAL_ID),
      MANUAL_DOCUMENT_ID,
    )
    repository.store(manual)
  end

  def self.down
    raise IrreversibleMigration
  end

private
  # These tie the code closely to how we've implemented repositories and
  # repository factories in the wiring. Best practice here would be to extract the
  # implementation to here to "freeze" it.
  def self.repository
    @repository ||= repository_factory.call("government-digital-service")
  end

  def self.repository_factory
    SpecialistPublisherWiring.get(:repository_registry).
      organisation_scoped_manual_repository_factory
  end
end
