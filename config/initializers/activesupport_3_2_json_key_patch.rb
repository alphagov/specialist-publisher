# This initializer has been added to patch CVE-2015-3226 (since no official
# upgrade was available at the time for the 3.2 branch of Rails)

# Beyond Rails version 3.2.22, this initializer should be removed if the
# vulnerability's been patched.
unless Rails::VERSION::STRING == "3.2.22"
  raise "Check monkey patch for CVE-2015-3226 is still needed"
end

module ActiveSupport
  module JSON
    module Encoding
      private
      class EscapedString
        def to_s
          self
        end
      end
    end
  end
end
