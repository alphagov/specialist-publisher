require "rails_helper"

RSpec.describe "Component guide", type: :request do
  it "redirects unauthenticated users to signon" do
    ENV["GDS_SSO_MOCK_INVALID"] = "1"

    get "/component-guide"

    expect(response).to redirect_to("/auth/gds")
  ensure
    ENV.delete("GDS_SSO_MOCK_INVALID")
  end

  it "allows access when signed in" do
    GDS::SSO.test_user = FactoryBot.create(:user)

    get "/component-guide"

    expect(response).to have_http_status(:success)
  end
end
