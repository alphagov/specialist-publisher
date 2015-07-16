domain = Plek.current.website_root

MANUAL_CONTENT_URL = if domain.include?  "dev"
                       "http://manuals-frontend.dev.gov.uk"
                     elsif domain.include? "preview"
                       "http://www.preview.alphagov.co.uk"
                     else
                       "https://www.gov.uk"
                     end

ORGANISATION_URL = if domain.include?  "dev"
                     "http://whitehall-admin.dev.gov.uk"
                   elsif domain.include? "preview"
                     "http://www.preview.alphagov.co.uk"
                   else
                     "https://www.gov.uk"
                   end
