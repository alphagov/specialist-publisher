Given(/^two "(.*?)" exist$/) do |documents|
  type = tribunal_decision_type(documents)
  create_tribunal_decision(type, title: "decision 1")
  create_tribunal_decision(type, title: "decision 2")
end

Then(/^the "(.*?)" should be in the publisher document index in the correct order$/) do |documents|
  visit tribunal_decision_path(documents)
  check_for_documents("decision 2", "decision 1")
end
