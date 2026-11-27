require "rails_helper"

RSpec.describe BulkDocumentUnpublisher do
  let(:format) { CmaCase }

  def csv(*lines)
    (["base_path,alternative_path"] + lines).join("\n")
  end

  def unpublisher(raw_csv)
    described_class.new(format, raw_csv).tap(&:validate)
  end

  describe "#validate" do
    it "accepts a CSV whose base paths all resolve to documents" do
      stub_publishing_api_has_lookups(
        "/cma-cases/one" => "11111111-1111-1111-1111-111111111111",
        "/cma-cases/two" => "22222222-2222-2222-2222-222222222222",
      )

      subject = unpublisher(csv("/cma-cases/one,/somewhere-else", "/cma-cases/two,"))

      expect(subject.errors).to be_empty
      expect(subject).to be_valid
      expect(subject.rows).to eq([
        { base_path: "/cma-cases/one", alternative_path: "/somewhere-else", content_id: "11111111-1111-1111-1111-111111111111" },
        { base_path: "/cma-cases/two", alternative_path: nil, content_id: "22222222-2222-2222-2222-222222222222" },
      ])
    end

    it "rejects a blank CSV" do
      expect(unpublisher("").errors).to eq(["Enter the CSV contents"])
    end

    it "rejects a malformed CSV" do
      subject = unpublisher(%(base_path,alternative_path\n"/cma-cases/one", "/elsewhere"))

      expect(subject.errors).to eq(["Malformed CSV, check for extra spaces or quotation marks"])
    end

    it "rejects unexpected headers" do
      subject = unpublisher("content_id,locale\n1234,en")

      expect(subject.errors).to eq([
        "Expected the following headers: base_path, alternative_path. Detected: content_id, locale",
      ])
    end

    it "rejects a CSV with headers but no rows" do
      expect(unpublisher(csv).errors).to eq(["Enter at least one row of CSV data"])
    end

    it "rejects a row with no base path" do
      expect(unpublisher(csv(",/somewhere-else")).errors).to eq(["Row 2: enter a base path"])
    end

    it "rejects a row with more fields than there are headers" do
      expect(unpublisher(csv("/cma-cases/one,/somewhere-else,extra")).errors).to eq([
        "Row 2: expected 2 fields but found 3",
      ])
    end

    it "accepts a row that omits the trailing comma for the alternative path" do
      stub_publishing_api_has_lookups("/cma-cases/one" => "11111111-1111-1111-1111-111111111111")

      subject = unpublisher(csv("/cma-cases/one"))

      expect(subject.errors).to be_empty
      expect(subject.rows.first[:alternative_path]).to be_nil
    end

    it "rejects a base path belonging to another document type" do
      subject = unpublisher(csv("/raib-reports/one,"))

      expect(subject.errors).to eq([
        "Row 2: /raib-reports/one is not a CMA Case path. Base paths must start with /cma-cases/",
      ])
    end

    it "rejects a base path that is the finder itself" do
      expect(unpublisher(csv("/cma-cases,")).errors).to eq([
        "Row 2: /cma-cases is not a CMA Case path. Base paths must start with /cma-cases/",
      ])
    end

    it "rejects an alternative path that is not a valid path" do
      subject = unpublisher(csv("/cma-cases/one,https://www.gov.uk/elsewhere"))

      expect(subject.errors).to eq([
        "Row 2: https://www.gov.uk/elsewhere is not a valid path. It must start with a slash, for example /cma-cases/another-case",
      ])
    end

    it "rejects a base path listed more than once" do
      subject = unpublisher(csv("/cma-cases/one,", "/cma-cases/one,/somewhere-else"))

      expect(subject.errors).to eq(["/cma-cases/one appears more than once"])
    end

    it "rejects a base path that does not exist in the publishing api" do
      stub_publishing_api_has_lookups("/cma-cases/one" => "11111111-1111-1111-1111-111111111111")

      subject = unpublisher(csv("/cma-cases/one,", "/cma-cases/missing,"))

      expect(subject.errors).to eq(["Document not found: /cma-cases/missing"])
      expect(subject).not_to be_valid
    end

    it "reports every invalid row rather than stopping at the first" do
      subject = unpublisher(csv(",", "/raib-reports/one,"))

      expect(subject.errors).to eq([
        "Row 2: enter a base path",
        "Row 3: /raib-reports/one is not a CMA Case path. Base paths must start with /cma-cases/",
      ])
    end

    it "does not look anything up when a row is invalid" do
      unpublisher(csv("/raib-reports/one,"))

      expect(a_request(:post, %r{/lookup-by-base-path})).not_to have_been_made
    end
  end

  describe "#summarise_changes" do
    it "describes whether each row will be made gone or redirected" do
      stub_publishing_api_has_lookups(
        "/cma-cases/one" => "11111111-1111-1111-1111-111111111111",
        "/cma-cases/two" => "22222222-2222-2222-2222-222222222222",
      )

      subject = unpublisher(csv("/cma-cases/one,/somewhere-else", "/cma-cases/two,"))

      expect(subject.summarise_changes).to eq([
        { base_path: "/cma-cases/one", action: "Unpublish and redirect to /somewhere-else" },
        { base_path: "/cma-cases/two", action: "Unpublish" },
      ])
    end
  end

  describe "#call" do
    let(:first_document) { instance_double(CmaCase, unpublish: true) }
    let(:second_document) { instance_double(CmaCase, unpublish: true) }

    before do
      stub_publishing_api_has_lookups(
        "/cma-cases/one" => "11111111-1111-1111-1111-111111111111",
        "/cma-cases/two" => "22222222-2222-2222-2222-222222222222",
      )
      allow(CmaCase).to receive(:find).with("11111111-1111-1111-1111-111111111111", "en").and_return(first_document)
      allow(CmaCase).to receive(:find).with("22222222-2222-2222-2222-222222222222", "en").and_return(second_document)
    end

    it "unpublishes every row, redirecting the rows that supply an alternative path" do
      subject = unpublisher(csv("/cma-cases/one,/somewhere-else", "/cma-cases/two,"))

      expect(subject.call).to be_empty

      expect(first_document).to have_received(:unpublish).with("/somewhere-else")
      expect(second_document).to have_received(:unpublish).with(nil)
    end

    it "carries on after a failed row and returns the base paths that failed" do
      allow(first_document).to receive(:unpublish).and_return(false)

      subject = unpublisher(csv("/cma-cases/one,", "/cma-cases/two,"))

      expect(subject.call).to eq(["/cma-cases/one"])
      expect(second_document).to have_received(:unpublish)
    end

    it "carries on after a row whose document cannot be fetched" do
      allow(CmaCase).to receive(:find)
        .with("11111111-1111-1111-1111-111111111111", "en")
        .and_raise(DocumentFinder::RecordNotFound)

      subject = unpublisher(csv("/cma-cases/one,", "/cma-cases/two,"))

      expect(subject.call).to eq(["/cma-cases/one"])
      expect(second_document).to have_received(:unpublish)
    end

    it "does nothing when the CSV was never validated" do
      expect(described_class.new(format, csv("/cma-cases/one,")).call).to be_empty
      expect(CmaCase).not_to have_received(:find)
    end
  end
end
