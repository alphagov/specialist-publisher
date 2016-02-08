module ManualsHelper

  def url_for_public_manual(manual)
    Plek.current.website_root + manual.base_path
  end

  def url_for_public_org(base_path)
    Plek.current.website_root + base_path
  end

end
