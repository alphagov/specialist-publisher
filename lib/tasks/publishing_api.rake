require "services"
require "thor"

def shell
  @shell ||= Thor::Shell::Basic.new
end

namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  # Do not use this unless you're sure the target_stack settings on your finders are correct. This will publish all finders with target_stack set to live.
  task publish_finders: :environment do
    finder_loader = FinderLoader.new

    unless shell.yes?("You're about to publish all finders to the Publishing API, proceed? (yes/no)")
      shell.say_error "Aborted"
      next
    end

    begin
      PublishingApiFinderPublisher.new(finder_loader.finders).call
    rescue GdsApi::HTTPServerError => e
      puts "Error publishing finder: #{e.inspect}"
    end
  end

  desc "Publish a single Finder to the Publishing API"
  task :publish_finder, [:name] => :environment do |_, args|
    begin
      finder_loader = FinderLoader.new
      finder = finder_loader.finder(args.name)
    rescue StandardError => e
      puts "Error: #{e.inspect}"
    end

    if finder
      begin
        unless shell.yes?("You're about to publish '#{finder[0][:file]['name']}' to the Publishing API. Proceed? (yes/no)")
          shell.say_error "Aborted"
          next
        end

        PublishingApiFinderPublisher.new(finder).call
      rescue GdsApi::HTTPServerError => e
        puts "Error publishing finder: #{e.inspect}"
      end
    end
  end
end
