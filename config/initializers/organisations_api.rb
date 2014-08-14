# In dev, we don't want to incur the cost of depending on Whitehall just for the organisations API
# In test, the organisations API stubs assume that the basepath is `Plek.current.find("whitehall-admin")`
# In preview, the client would have to handle simple auth so pointing to production is simpler

ORGANISATIONS_API_BASE_PATH = if Rails.env.test?
                                Plek.current.find("whitehall-admin")
                              else
                                "https://www.gov.uk"
                              end
