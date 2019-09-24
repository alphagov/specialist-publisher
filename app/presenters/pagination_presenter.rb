require "ostruct"

class PaginationPresenter < SimpleDelegator
  attr_reader :current_page, :total_pages, :total_count, :limit_value

  def initialize(api_response, _per_page)
    # actually delegate to the API response's `results` array
    super(present_results(api_response["results"]))

    @current_page = api_response["current_page"]
    @total_pages = api_response["pages"] || 1
    @total_count = api_response["total"]
  end

private

  def present_results(results)
    results.map { |entry| OpenStruct.new(entry) }
  end
end
