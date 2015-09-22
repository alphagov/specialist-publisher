module AttachmentHelpers
  def test_asset_manager_base_url
    Plek.current.find("asset-manager")
  end

  def add_attachment_to_manual_document(document_title, attachment_title)
    if page.has_css?("a", text: document_title)
      click_on(document_title)
    elsif page.has_css?("a", text: "Edit")
      click_on("Edit")
    end

    add_attachment_to_document(document_title, attachment_title)
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

  def copy_embed_code_for_attachment_and_paste_into_body(title, body_selector)
    snippet = within(".attachments") do
      page
        .find("li", text: /#{title}/)
        .find("span.snippet")
        .text
    end

    body_text = find(body_selector).value
    fill_in("Body", with: body_text + snippet)
  end

  def check_preview_contains_attachment_link(title)
    within(".preview") do
      expect(page).to have_css("a", text: title)
    end
  end

  def create_case_with_attachment(document_title, attachment_title)
    create_cma_case(
      title: document_title,
      summary: "Eget urna mollis ornare vel eu leo.",
      body: ("Praesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
      opened_date: "2014-01-01",
      market_sector: "Energy",
    )

    add_attachment_to_document(document_title, attachment_title)
  end

  def edit_attachment(document_title, attachment_title, new_attachment_title, new_attachment_file_name)
    attachment_li = page.find(".attachments li", text: attachment_title)
    attachment_edit_link = attachment_li.find("a", text: "edit")

    within(attachment_li) do
      click_link("edit")
    end

    fill_in "Title", with: new_attachment_title
    attach_file "File", fixture_filepath(new_attachment_file_name)

    stub_request(:put, "#{test_asset_manager_base_url}/assets/#{asset_id}")
      .to_return(
        body: JSON.dump(asset_manager_response),
        status: 200,
      )

    click_button "Save attachment"
  end

  def check_for_attachment_update(document_title, attachment_title, attachment_file_name)
    expect(page).to have_css(".attachments li", text: @new_attachment_title)
    expect(page).to have_css(".attachments li", text: @new_attachment_file_name)
  end

  def add_attachment_to_document(document_title, attachment_title)
    unless current_path.include?("edit")
      click_link "Edit"
    end

    click_on "Add attachment"
    fill_in "Title", with: attachment_title
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
end
RSpec.configuration.include AttachmentHelpers, type: :feature
