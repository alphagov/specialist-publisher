require "services"
require "thor"

def shell
  @shell ||= Thor::Shell::Basic.new
end

namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
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

    puts "You're about to publish #{finder} to the Publishing API"
    unless shell.yes?("Would you like to proceed with publishing this? (yes/no)")
      shell.say_error "Aborted"
      next
    end

    if finder
      begin
        PublishingApiFinderPublisher.new(finder).call
      rescue GdsApi::HTTPServerError => e
        puts "Error publishing finder: #{e.inspect}"
      end
    end
  end
end
