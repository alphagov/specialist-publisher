require "spec_helper"
require "formatters/manual_section_indexable_formatter"

RSpec.describe ManualSectionIndexableFormatter do

  let(:section) {
    double(
      :manual_section,
      title: double,
      summary: double,
      slug: "",
      body: double,
    )
  }
  let(:manual) {
    double(
      :manual,
      title: double,
      organisation_slug: double,
      slug: "",
    )
  }

  subject(:formatter) { ManualSectionIndexableFormatter.new(section, manual) }

  describe "as an indexable formatter" do
    it_behaves_like "an indexable formatter"
  end

end
