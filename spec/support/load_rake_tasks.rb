RSpec.configure do |config|
  config.before :each, rake_task: true do
    Rake.application.clear
    Rails.application.load_tasks
  end
end
