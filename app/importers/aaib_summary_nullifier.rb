class AaibSummaryNullifier
  def initialize(repo, import_mapper)
    @repo = repo
    @import_mapper = import_mapper
  end

  def call(data)
    import_mapper.call(data).tap do |document|
      # Remove the temporarily inserted summary, skipping validations
      # Yay demeter. Yay hack.
      document.editions.last.update_attribute(:summary, nil)
    end
  end

private
  attr_reader :repo, :import_mapper
end
