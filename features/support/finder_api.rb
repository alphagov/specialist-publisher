def stub_finder_api
  stub_request(:put, %r{https?://finder-api\.\w+\.gov\.uk/finders/.*}).
    to_return(:status => 200, :body => "", :headers => {})

  # Stub this so RSpec can spy on it
  allow(finder_api).to receive(:notify_of_publication).and_call_original
end
