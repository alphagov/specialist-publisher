require "spec_helper"
require "importers/licence_transaction/tagging_csv_validator"

RSpec.describe Importers::LicenceTransaction::TaggingCsvValidator do
  let(:tagging) do
    [
      {
        "base_path" => "/licence",
        "locations" => %w[england],
        "industries" => %w[street-trading-and-markets],
      },
    ]
  end

  it "returns true if tagging is valid" do
    expect(described_class.new(tagging).valid?).to be true
  end

  context "when the tagging in invalid" do
    it "returns false" do
      tagging.first["locations"] = %w[random-place]
      expect(described_class.new(tagging).valid?).to be false
    end

    it "returns errors for invalid location tagging" do
      error_message = tagging_template_message("- unrecognised locations: '[\"random-place\"]'")

      tagging.first["locations"] = %w[random-place]
      expect { described_class.new(tagging).errors }
        .to output(error_message).to_stdout
    end

    it "returns errors for invalid industry tagging" do
      error_message = tagging_template_message("- unrecognised industries: '[\"something-this-isnt-an-industry\"]'")

      tagging.first["industries"] = %w[something-this-isnt-an-industry]
      expect { described_class.new(tagging).errors }
        .to output(error_message).to_stdout
    end
  end
end

def tagging_template_message(error_messages)
  <<~HEREDOC
    CSV errors for '/licence':
    #{error_messages}

    Please read the instructions (under heading 'Update tagging') in the following link to resolve the unrecognised
    tags errors: https://trello.com/c/2SBbuD8N/1969-how-to-correct-unrecognised-tags-when-importing-licences
  HEREDOC
end
