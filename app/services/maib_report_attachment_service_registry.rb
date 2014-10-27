class MaibReportAttachmentServiceRegistry < AbstractAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:maib_report_repository)
  end
end
