# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)

SpecialistPublisher::Application.load_tasks

task :rubocop do
  system("bin/rubocop")

  exit_code = $?.exitstatus
  exit(exit_code) unless exit_code == 0
end

task default: [
  "rubocop",
  "spec:javascript",
  "spec",
  "cucumber",
  ]
