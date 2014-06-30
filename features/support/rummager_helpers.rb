def stub_rummager
  stub_request(:post, %r{https?://search\.\w+\.gov\.uk/documents}).
    to_return(status: 200, body: "", headers: {})

  stub_request(:delete, %r{https?://search\.\w+\.gov\.uk/documents/.*}).
    to_return(status: 200, body: "", headers: {})
end
