require "spec_helper"
require "formatters/medical_safety_alert_indexable_formatter"

RSpec.describe MedicalSafetyAlertIndexableFormatter do
  let(:document) {
    double(
      :medical_safety_alert,
      body: double,
      slug: double,
      summary: double,
      title: double,
      updated_at: double,
      minor_update?: false,
      alert_type: double,
      medical_specialism: double,
      issued_date: double
    )
  }

  subject(:formatter) { MedicalSafetyAlertIndexableFormatter.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of medical_safety_alert" do
    expect(formatter.type).to eq("medical_safety_alert")
  end
end
