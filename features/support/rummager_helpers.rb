def stub_rummager
  stub_request(:post, %r{https?://search\.\w+\.gov\.uk/documents}).
    to_return(status: 200, body: "", headers: {})

  stub_request(:delete, %r{https?://search\.\w+\.gov\.uk/documents/.*}).
    to_return(status: 200, body: "", headers: {})

  # Allow RSpec to spy on the Rummager API adapter
  allow(rummager_api).to receive(:add_document).and_call_original
  allow(rummager_api).to receive(:delete_document).and_call_original
end

def reset_rummager_stubs_and_messages
  RSpec::Mocks.proxy_for(rummager_api).reset
  stub_rummager
end
