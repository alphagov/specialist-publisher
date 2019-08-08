desc "Find CMA Cases with opened dates that are before closed dates"
task opened_before_closed_dates: :environment do
  cma_cases = Services.publishing_api.get_content_items(
    document_type: "cma_case",
    per_page: 999999,
  ).results

  non_blank_opened_dates = cma_cases.reject { |cma| cma.details.metadata.opened_date.blank? }
  non_blank_closed_dates = cma_cases.reject { |cma| cma.details.metadata.closed_date.blank? }

  non_blank_opened_dates.each do |cma|
    if non_blank_closed_dates.include? cma
      unless cma.details.metadata.opened_date <= cma.details.metadata.closed_date
        puts "Opened date is before closed date. Opened: #{cma.details.metadata.opened_date}, Closed: #{cma.details.metadata.closed_date}, content_id: #{cma.content_id}"
      end
    end
  end
end
