require 'gds_api/content_store'
require 'csv'

desc "Unpublish NI and Wales schemes from business support finder"
task unpublish_ni_wales_finders: :environment do
  @content_store ||= GdsApi::ContentStore.new(Plek.current.find("content-store"))
  base_paths = CSV.read('lib/tasks/finders.csv', headers: true)['base_path']
  unpublished = []
  invalid = []
  not_found = []
  unpublishing_error = []
  base_paths.each do |base_path|
    begin
      content_item = @content_store.content_item(base_path)
    rescue GdsApi::HTTPGone
      unpublished << base_path
    rescue GdsApi::InvalidUrl
      invalid << base_path
    rescue GdsApi::ContentStore::ItemNotFound
      not_found << base_path
    end
    if content_item.present?
      begin
        DocumentUnpublisher.unpublish(content_item["content_id"], base_path)
      rescue => e
        unpublishing_error << "#{base_path} > #{e.class.name} #{e.message}"
      end
    end
  end
  print_summary(unpublished, invalid, not_found, unpublishing_error)
end

def print_summary(unpublished, invalid, not_found, unpublishing_error)
  puts "\nSummary"
  puts ">#{unpublished.count} items already unpublished"
  puts unpublished if unpublished.present?
  puts "> #{invalid.count} invalid URLs"
  puts invalid if invalid.present?
  puts "> #{not_found.count} items not found in Content Store"
  puts not_found if not_found.present?
  puts "> #{unpublishing_error.count} unpublishing errors"
  puts unpublishing_error if unpublishing_error.present?
end
