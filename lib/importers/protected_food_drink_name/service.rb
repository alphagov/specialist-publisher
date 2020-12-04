require "services"
require "importers/protected_food_drink_name/parser"

module Importers
  module ProtectedFoodDrinkName
    class Service
      class Result
        attr_accessor :error

        def initialize
          @error = ""
        end

        def successful?
          error.blank?
        end
      end

      def self.call(args)
        new.call(args)
      end

      def call(row)
        result = Result.new

        parser = Parser.new(row)

        begin
          document = ::ProtectedFoodDrinkName.new(parser.get_attributes)

          unless Services.with_timeout(30) { document.save }
            validation_errors = document.errors.full_messages.join(". ")
            result.error = "Registered name: #{document.title}. #{validation_errors}"
          end
        rescue StandardError => e
          result.error = "Registered name: #{document&.title}. #{e.message}\nBacktrace: #{e.backtrace[0..10].join("\n")}"
        end

        # give it time to breathe... why not...
        sleep 2

        result
      end
    end
  end
end
