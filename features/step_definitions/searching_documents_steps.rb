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

  fill_in "Search term", with: @searching_for[:slug]
  choose "Slug"
  click_on "Search"
end

When(/^I search for a partial slug$/) do
  visit aaib_reports_path

  @searching_for = @aaib_reports_data.first

  # 0..18 => "aaib-reports/first-"
  fill_in "Search term", with: @searching_for[:slug][0..18]
  choose "Slug"
  click_on "Search"
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
  fill_in "Search term", with: @searching_for[:title][0..4]
  choose "Title"
  click_on "Search"
end

When(/^I search for a partial title in the wrong case$/) do
  visit aaib_reports_path

  @searching_for = @aaib_reports_data.last

  # 0..4 => "THIRD"
  fill_in "Search term", with: @searching_for[:title][0..4].upcase
  choose "Title"
  click_on "Search"
end

Given(/^a search has been performed$/) do
  visit aaib_reports_path

  fill_in "Search term", with: "Any data"
  choose "Title"
  click_on "Search"
end

When(/^I clear the search term field$/) do
  fill_in "Search term", with: ""
  click_on "Search"
end

Then(/^I see all AAIB reports in the list$/) do
  aaib_reports_are_visible(@aaib_reports_data.map { |r| r[:title] })
end
