require "services"

namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  task publish_finders: :environment do
    finder_loader = FinderLoader.new

    unless Thor::Shell::Basic.new.yes?("You're about to publish all finders to the Publishing API, proceed? (yes/no)")
      puts "Aborted"
      exit 1
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
    unless Thor::Shell::Basic.new.yes?("Would you like to proceed with publishing this? (yes/no)")
      puts "Aborted"
      exit 1
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
