task import: [:environment] do
  file = RestClient.get(ENV['URL_TO_REPORTS_JSON'])
  reports = JSON.parse(file)
  reports.each do |report|
    ServiceStandardReport.new(
      body: report.fetch("body"),
      title: report.fetch("title"),
      summary: report.fetch("summary"),
    ).save
  end
end
