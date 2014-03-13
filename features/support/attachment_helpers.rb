module AttachmentHelpers
  def test_asset_manager_base_url
    Plek.current.find("asset-manager")
  end

  def add_attachment_to_case(document_title)
    click_on document_title
    click_on "Add attachment"
    fill_in "Title", with: "My attachment"
    attach_file "File", File.expand_path("../fixtures/greenpaper.pdf", File.dirname(__FILE__))

    stub_request(:post, "#{test_asset_manager_base_url}/assets")
      .to_return(
        body: JSON.dump(asset_manager_response),
        status: 201,
      )

    stub_request(:get, "#{test_asset_manager_base_url}/assets/#{asset_id}")
      .to_return(
        body: JSON.dump(asset_manager_response),
        status: 200,
      )

    click_on "Save attachment"
  end

  def asset_id
    "513a0efbed915d425e000002"
  end

  def asset_manager_response
    {
      "_response_info" => {
        "status" => "ok"
      },
      "content_type" => "image/jpeg",
      "file_url" => "https://stubbed-asset-manager.alphagov.co.uk/media/#{asset_id}/greenpaper.pdf",
      "id" => "https://stubbed-asset-manager.alphagov.co.uk/assets/#{asset_id}",
      "name" => "greenpaper.pdf",
      "state" => "clean"
    }
  end

  def check_for_an_attachment
    within(".attachments") do
      expect(page).to have_content("My attachment")
      expect(page).to have_content("[InlineAttachment:greenpaper.pdf]")
    end
  end

  def copy_embed_code_for_attachment_and_paste_into_body(title)
    snippet = within(".attachments") do
      page
        .find("li", text: /#{title}/)
        .find("span.snippet")
        .text
    end

    body_text = find("#specialist_document_body").value
    fill_in("Body", with: body_text + snippet)
  end

  def check_preview_contains_attachment_link(title)
    within(".preview") do
      expect(page).to have_css("a", text: title)
    end
  end
end
