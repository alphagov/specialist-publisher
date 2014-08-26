module IdfHelpers
  def create_international_development_fund(*args)
    create_document(:international_development_fund, *args)
  end

  def go_to_show_page_for_international_development_fund(*args)
    go_to_show_page_for_document(:international_development_fund, *args)
  end

  def check_international_development_fund_exists_with(*args)
    check_document_exists_with(:international_development_fund, *args)
  end

  def go_to_international_development_fund_index
    visit_path_if_elsewhere(international_development_funds_path)
  end

  def go_to_edit_page_for_international_development_fund(*args)
    go_to_edit_page_for_document(:international_development_fund, *args)
  end

  def edit_international_development_fund(*args)
    edit_document(:international_development_fund, *args)
  end

  def check_for_new_international_development_fund_title(*args)
    check_for_new_document_title(:international_development_fund, *args)
  end

  def withdraw_international_development_fund(*args)
    withdraw_document(:international_development_fund, *args)
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
