require "cli_manual_deleter"

When(/^I run the deletion script$/) do
  @stdin = double(:stdin)
  # If we cared about checking string output we'd make this a StringIO
  null_stdout = double(:null_output_io, puts: nil)
  @deleter = CliManualDeleter.new(@manual_slug, stdin: @stdin, stdout: null_stdout)
end

When(/^I confirm deletion/) do
  allow(@stdin).to receive(:gets).and_return("Yes")
  @deleter.call
end

When(/^I refuse deletion/) do
  allow(@stdin).to receive(:gets).and_return("No")
  expect { @deleter.call }.to raise_error
end

Then(/^the script raises an error/) do
  expect { @deleter.call }.to raise_error
end

Then(/^the manual and its documents are deleted$/) do
  check_manual_does_not_exist_with(@manual_fields)
end

Then(/^the manual and its documents still exist$/) do
  check_manual_exists_with(@manual_fields)
end
