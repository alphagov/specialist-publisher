module FileFixtureHelpers
  def fixture_filepath(filename)
    filepath = File.expand_path("../fixtures/#{filename}", File.dirname(__FILE__))
    raise "Fixture #{filename} not found" unless File.exists?(filepath)

    filepath
  end
end
RSpec.configuration.include FileFixtureHelpers, type: :feature
