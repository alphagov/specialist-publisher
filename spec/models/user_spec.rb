require "rails_helper"
require "gds-sso/lint/user_spec"

RSpec.describe User, type: :model do
  it_behaves_like "a gds-sso user class"

  it "returns gds_editor? false if user does not have gds editor permissions" do
    user = User.new(permissions: [])
    expect(user.gds_editor?).to be false
  end

  it "returns gds_editor? true if user has gds editor permissions" do
    user = User.new(permissions: %w[gds_editor])
    expect(user.gds_editor?).to be true
  end
end
