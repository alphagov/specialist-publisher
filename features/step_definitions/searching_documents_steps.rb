Given(/^multiple draft AAIB reports exist$/) do
  @aaib_reports_data = [
    {title: "First AAIB report", slug: "aaib-reports/first-aaib-report"},
    {title: "Second AAIB report", slug: "aaib-reports/second-aaib-report"},
    {title: "Third AAIB report", slug: "aaib-reports/third-aaib-report"},
  ]

  titles = @aaib_reports_data.map { |r| r[:title] }

  create_multiple_aaib_reports(titles)
end

When(/^I search for an exact slug$/) do
  visit aaib_reports_path

  @searching_for = @aaib_reports_data.first

  search_for(@searching_for[:slug])
end

When(/^I search for a partial slug$/) do
  visit aaib_reports_path

  @searching_for = @aaib_reports_data.first

  # 0..18 => "aaib-reports/first-"
  search_for(@searching_for[:slug][0..18])
end

Then(/^I see the matching AAIB reports in the list$/) do
  aaib_report_is_visible(@searching_for[:title])

  non_matching_titles = (@aaib_reports_data - [@searching_for]).map { |r| r[:title] }

  aaib_reports_are_not_visible(non_matching_titles)
end

When(/^I search for a partial title$/) do
  visit aaib_reports_path

  @searching_for = @aaib_reports_data.last

  # 0..4 => "Third"
  search_for(@searching_for[:title][0..4])
end

When(/^I search for a partial title in the wrong case$/) do
  visit aaib_reports_path

  @searching_for = @aaib_reports_data.last

  # 0..4 => "THIRD"
  search_for(@searching_for[:title][0..4].upcase)
end

Given(/^a search has been performed$/) do
  visit aaib_reports_path
  search_for("Any data")
end

When(/^I clear the search field$/) do
  search_for("")
end

Then(/^I see all AAIB reports in the list$/) do
  aaib_reports_are_visible(@aaib_reports_data.map { |r| r[:title] })
end
