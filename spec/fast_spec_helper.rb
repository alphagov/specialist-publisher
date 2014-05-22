Dir.glob("app/*").each do |app_subdir|
  $LOAD_PATH.unshift(File.expand_path(app_subdir))
end

require "pry"
require "awesome_print"
require "active_support/core_ext/hash"

# RSpec.configure do |config|
#   config.disable_monkey_patching!
# end
