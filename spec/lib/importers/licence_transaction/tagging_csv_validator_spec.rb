require "spec_helper"
require "importers/licence_transaction/tagging_csv_validator"

RSpec.describe Importers::LicenceTransaction::TaggingCsvValidator do
  let(:organisations) do
    [
      Organisation.new("content_id" => "12335", "title" => "Org title"),
      Organisation.new("content_id" => "54321", "title" => "Org title 2"),
    ]
  end
  let(:tagging) do
    [
      {
        "base_path" => "/licence",
        "locations" => %w[england],
        "industries" => %w[street-trading-and-markets],
        "primary_publishing_organisation" => ["Org title"],
        "organisations" => [],
      },
    ]
  end

  it "returns true if tagging is valid" do
    expect(described_class.new(tagging, organisations).valid?).to be true
  end

  context "when the tagging in invalid" do
    it "returns false" do
      tagging.first["locations"] = %w[random-place]
      expect(described_class.new(tagging, organisations).valid?).to be false
    end

    it "returns errors for invalid location tagging" do
      error_message = tagging_template_message("- unrecognised locations: '[\"random-place\"]'")

      tagging.first["locations"] = %w[random-place]
      expect { described_class.new(tagging, organisations).errors }
        .to output(error_message).to_stdout
    end

    it "returns errors for invalid industry tagging" do
      error_message = tagging_template_message("- unrecognised industries: '[\"something-this-isnt-an-industry\"]'")

      tagging.first["industries"] = %w[something-this-isnt-an-industry]
      expect { described_class.new(tagging, organisations).errors }
        .to output(error_message).to_stdout
    end

    it "returns errors when primary publishing organisation is blank" do
      error_message = tagging_template_message("- primary publishing organisation blank")

      tagging.first["primary_publishing_organisation"] = []
      expect { described_class.new(tagging, organisations).errors }
        .to output(error_message).to_stdout
    end

    it "returns errors when there is more than one primary publishing organisation" do
      error_message = tagging_template_message("- more than one primary publishing organisation: '[\"Org title\", \"Org title 2\"]'")

      tagging.first["primary_publishing_organisation"] = ["Org title", "Org title 2"]
      expect { described_class.new(tagging, organisations).errors }
        .to output(error_message).to_stdout
    end

    it "returns errors when primary publishing organisation doesn't exist" do
      error_message = tagging_template_message("- primary publishing organisation doesn't exist: '[\"Missing org\"]'")

      tagging.first["primary_publishing_organisation"] = ["Missing org"]
      expect { described_class.new(tagging, organisations).errors }
        .to output(error_message).to_stdout
    end

    it "returns errors when present organisations don't exist" do
      error_message = tagging_template_message("- organisations don't exist: '[\"Missing org\"]'")

      tagging.first["organisations"] = ["Missing org"]
      expect { described_class.new(tagging, organisations).errors }
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
