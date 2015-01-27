module CsgHelpers
  def create_countryside_stewardship_grant(*args)
    create_document(:countryside_stewardship_grant, *args)
  end

  def go_to_show_page_for_countryside_stewardship_grant(*args)
    go_to_show_page_for_document(:countryside_stewardship_grant, *args)
  end

  def check_countryside_stewardship_grant_exists_with(*args)
    check_document_exists_with(:countryside_stewardship_grant, *args)
  end

  def go_to_countryside_stewardship_grant_index
    visit_path_if_elsewhere(countryside_stewardship_grants_path)
  end

  def go_to_edit_page_for_countryside_stewardship_grant(*args)
    go_to_edit_page_for_document(:countryside_stewardship_grant, *args)
  end

  def edit_countryside_stewardship_grant(title, *args)
    go_to_edit_page_for_countryside_stewardship_grant(title)
    edit_document(title, *args)
  end

  def check_for_new_countryside_stewardship_grant_title(*args)
    check_for_new_document_title(:countryside_stewardship_grant, *args)
  end

  def withdraw_countryside_stewardship_grant(*args)
    withdraw_document(:countryside_stewardship_grant, *args)
  end

  def check_header_metadata_depth_is_limited(slug, depth: 1)
    published_document = RenderedSpecialistDocument.find_by_slug(slug)

    headers = published_document.details.fetch("headers")

    expect(find_header_depths(headers).max).to eq(depth)
  end

  def document_body_with_deeply_nested_headers
    %{

      ## Header

      Praesent commodo cursus magna, vel scelerisque nisl consectetur et.

      ### Level 2

      Praesent commodo cursus magna, vel scelerisque nisl consectetur et.

      #### Level 3

      Praesent commodo cursus magna, vel scelerisque nisl consectetur et.

      ##### Level 4

      Praesent commodo cursus magna, vel scelerisque nisl consectetur et.

    }
  end

  def find_header_depths(headers, current_depth = 0)
    if headers.empty?
      current_depth
    else
      headers.flat_map { |h| find_header_depths(h.fetch("headers"), current_depth + 1) }
    end
  end
end
