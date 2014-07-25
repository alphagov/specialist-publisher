class InternationalDevelopmentFundAttachmentServiceRegistry < AbstractAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:international_development_fund_repository)
  end
end
