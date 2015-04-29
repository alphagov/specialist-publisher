When(/^I create a Vehicle Recalls and Faults alert$/) do
  create_a_draft_of_vehicle_fault_alert
end

Then(/^I should see that Vehicle Recalls and Faults alert$/) do
  check_vehicle_recalls_and_faults_alert_exists_with(@document_fields)
end

When(/^I try to save a Vehicle Recall alert with invalid HTML and no title$/) do
  @invalid_fields = {
    title: nil,
    summary: nil,
    body: "<p< A paragraph about <script>alert('h4x0r')</script>",
    alert_issue_date: "99-99/99"
  }
  create_vehicle_recalls_and_faults_alert(@invalid_fields)
end

Then(/^the Vehicle Recall alert is not persisted$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft of a Vehicle Recalls and Faults alert exists$/) do
  create_a_draft_of_vehicle_fault_alert
end

When(/^I edit the Vehicle Recalls and Faults alert and remove summary$/) do
  edit_vehicle_recalls_and_faults_alert(@document_title, summary: "")
end

Then(/^the Vehicle Recalls and Faults alert should show an error for the summary$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two Vehicle Recalls and Faults alerts exist$/) do
  2.times do |index|
    document_fields = {
      title: "Example fault #{index}",
      summary: "Example summary #{index}",
      body: "Example Content #{index}",
      alert_issue_date: "2015-04-28"
    }
    create_vehicle_recalls_and_faults_alert(document_fields)
  end
end

Then(/^the Vehicle Recalls and Faults alerts should be in the publisher CSG index$/) do
  visit vehicle_recalls_and_faults_alerts_path

  check_for_documents("Example fault 0", "Example fault 1")
end

When(/^I change the title of that Vehicle Recalls and Faults alert to "(.*?)"$/) do |new_title|
  edit_vehicle_recalls_and_faults_alert(@document_title, title: new_title)
end

Then(/^I should see "(.*?)" as the title fo the Vehicle Recalls and Faults alert$/) do |title|
  visit vehicle_recalls_and_faults_alerts_path
  check_for_documents(title)
end

Then(/^the Vehicle Recalls and Faults alert should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the Vehicle Recalls and Faults alert$/) do
  go_to_show_page_for_vehicle_recalls_and_faults_alert(@document_title)
  publish_document
end

Then(/^the Vehicle Recalls and Faults alert should be published$/) do
  check_document_is_published(@slug, @document_fields)
end

When(/^I publish a new Vehicle Recalls and Faults alert$/) do
  create_a_draft_of_vehicle_fault_alert(publish: true)
end

When(/^I am on the Vehicle Recalls and Faults alert edit page$/) do
  go_to_edit_page_for_vehicle_recalls_and_faults_alert(@document_fields.fetch(:title))
end

Given(/^a published Vehicle Recalls and Faults alert exists$/) do
  create_a_draft_of_vehicle_fault_alert(publish: true)
end

def create_a_draft_of_vehicle_fault_alert(options = {})
  @document_title = "Example Vehicle Recall"
  @slug = "vehicle-recalls-faults/example-vehicle-recall"
  @document_fields = {
    title: @document_title,
    summary: "Summary of the vehicle recall",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    alert_issue_date: "2015-04-28"
  }

  create_vehicle_recalls_and_faults_alert(@document_fields, options)
end
