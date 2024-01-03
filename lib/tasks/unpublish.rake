require "services"

namespace :unpublish do
  desc "Unpublish a Finder by file name and redirect the finder page to specific URL"
  task :redirect_finder, %i[finder_file redirect_url] => :environment do |_, args|
    schema = FinderLoader.new.finder(args.finder_file).first[:file]
    puts "=== Finder found ==="
    puts "Slug: #{schema['base_path']}"
    puts "Finder name: #{schema['name']}"
    puts "Content ID: #{schema['content_id']}"
    puts "Redirecting to: #{args.redirect_url}"

    begin
      response = GdsApi.publishing_api.unpublish(
        schema["content_id"],
        type: "redirect",
        alternative_path: args.redirect_url,
        discard_drafts: true,
      )
      puts "Publishing API response #{response.code}: #{response.raw_response_body}"
      puts "Finder unpublished"
    rescue GdsApi::HTTPServerError => e
      puts "Error unpublishing finder: #{e.inspect}"
    end
  end
end
