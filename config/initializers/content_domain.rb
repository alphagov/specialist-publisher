domain = Plek.current.website_root

MANUAL_CONTENT_URL = if domain.include?  "dev"
                       "http://manuals-frontend.dev.gov.uk"
                     elsif domain.include? "preview"
                       "http://www.preview.alphagov.co.uk"
                     else
                       "https://www.gov.uk"
                     end
