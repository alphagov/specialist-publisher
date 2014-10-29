class RaibReportAttachmentServiceRegistry < AbstractAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:raib_report_repository)
  end
end
