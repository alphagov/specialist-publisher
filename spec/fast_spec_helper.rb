$LOAD_PATH.unshift(File.expand_path("../app/models", File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path("../app/repositories", File.dirname(__FILE__)))

require "pry"
require "awesome_print"
require "active_support/core_ext/hash"
