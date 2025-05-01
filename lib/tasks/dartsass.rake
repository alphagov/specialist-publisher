require "dartsass/runner"

namespace :dartsass do
  desc "Watch and build your Dart Sass CSS on file changes, using polling"
  task watch_poll: :environment do
    system(*Dartsass::Runner.dartsass_compile_command, "--watch", "--poll", exception: true)
  end
end
