def stub_finder_api
  stub_request(:put, %r{https?://finder-api\.\w+\.gov\.uk/finders/.*}).
    to_return(:status => 200, :body => "", :headers => {})

end
