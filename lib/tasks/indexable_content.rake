require 'gds_api/content_store'

# TODO: Delete this rake task once the missing field has been populated

# Identify pages in finders which have missing search content.
#
# Specialist documents have a hidden field which is used just for search
# indexing, but this data is missing from Rummager for many documents. This rake
# task finds those documents so that they can be republished.
task find_unindexed_content: :environment do
  finders = [
    "/administrative-appeals-tribunal-decisions",
    "/tax-and-chancery-tribunal-decisions",
    "/asylum-support-tribunal-decisions",
    "/employment-tribunal-decisions",
    "/employment-appeal-tribunal-decisions",
  ]

  missing_content = IndexableContentChecker.new.check_content(finders)

  puts "Pages with missing hidden indexable content:"

  missing_content.each do |finder, pages|
    puts "Finder '#{finder}' has #{pages.size} pages where the hidden indexable content is missing"
  end
end

class IndexableContentChecker
  def initialize
    @content_store = GdsApi::ContentStore.new(
      Plek.find("content-store"),
      disable_cache: true
    )
    @rummager = Services.rummager
  end

  def check_content(finder_paths)
    missing_content = {}

    finder_paths.each do |finder_path|
      finder = @content_store.content_item(finder_path)
      pages_with_missing_content = []

      search_results(finder).each do |search_result|
        path = search_result["link"]
        content_item = @content_store.content_item(path)

        hidden_indexable_content = content_item["details"]["metadata"]["hidden_indexable_content"]

        if hidden_indexable_content && (search_result["indexable_content"].nil? || !search_result["indexable_content"].include?(hidden_indexable_content))
          pages_with_missing_content << path
        end
      end

      missing_content[finder_path] = pages_with_missing_content
    end

    missing_content
  end

private

  def search_results(finder)
    filter = finder["details"]["filter"].first
    filter_name, filter_value = filter

    page_size = 50
    page = 0

    found_all_results = false

    Enumerator.new do |yielder|
      while !found_all_results
        puts "Fetching page #{page} of finder #{finder['base_path']}"

        rummager_params = {
          "fields" => "link,indexable_content",
          "filter_#{filter_name}" => filter_value,
          "count" => page_size,
          "start" => page * page_size,
        }
        finder_search_results = @rummager.search(rummager_params)

        finder_search_results["results"].each do |result|
          yielder << result
        end

        page += 1

        if page * page_size > finder_search_results["total"]
          found_all_results = true
        end
      end
    end
  end
end
