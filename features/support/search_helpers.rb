module SearchHelpers
  def search_for(query)
    fill_in "Search", with: query
    click_on "Search"
  end
end
RSpec.configuration.include SearchHelpers, type: :feature
