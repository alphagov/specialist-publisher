# This tasks will publish documents that are in a draft publication state.

require "services"

namespace :publish do
  desc "Publishes all documents of given types in a draft publication state.\n" \
    "Usage: `rake publish:all[protected_food_drink_name,esi_fund]`"
  task :all, [:document_types] => :environment do |_, args|
    types = args.document_types.presence&.split(" ")&.compact

    raise ArgumentError, "No type given." if types.empty?

    Publisher.publish_all(types:)
  end
end
