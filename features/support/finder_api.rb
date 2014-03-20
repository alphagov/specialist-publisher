def stub_finder_api
  stub_request(:post, %r{https?://finder-api\.\w+\.gov\.uk/finders/cma-cases}).
    to_return(:status => 200, :body => "", :headers => {})
end
