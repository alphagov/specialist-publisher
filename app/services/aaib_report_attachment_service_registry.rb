class AaibReportAttachmentServiceRegistry < AbstractAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:aaib_report_repository)
  end
end
