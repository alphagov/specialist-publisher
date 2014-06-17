require "securerandom"

class IdGenerator
  def self.call
    SecureRandom.uuid
  end
end
