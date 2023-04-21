require "spec_helper"
require "importers/licence_transaction/tagging_csv_validator"

RSpec.describe Importers::LicenceTransaction::TaggingCsvValidator do
  it "returns true if tagging is valid" do
    tagging = [
      {
        "base_path" => "/licence",
        "locations" => %w[england],
        "industries" => %w[street-trading-and-markets],
      },
    ]

    expect(described_class.new(tagging).valid?).to be true
  end

  context "when the tagging in invalid" do
    let(:tagging) do
      [
        {
          "base_path" => "/licence",
          "locations" => %w[random-place],
          "industries" => %w[something-this-isnt-an-industry],
        },
      ]
    end

    it "returns false" do
      expect(described_class.new(tagging).valid?).to be false
    end

    it "returns errors for invalid tagging" do
      error_message = <<~HEREDOC
        Unrecognised tags for /licence:
         locations: ["random-place"],
         industries: ["something-this-isnt-an-industry"]

        Please read the instructions (under heading 'Update tagging') in the following link to resolve the unrecognised
        tags errors: https://trello.com/c/2SBbuD8N/1969-how-to-correct-unrecognised-tags-when-importing-licences
      HEREDOC

      expect { described_class.new(tagging).errors }
        .to output(error_message).to_stdout
    end
  end
end
