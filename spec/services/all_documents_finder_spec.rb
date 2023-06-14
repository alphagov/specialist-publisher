require "spec_helper"

RSpec.describe AllDocumentsFinder do
  subject { described_class }

  describe ".all" do
    let(:documents) do
      [
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/1",
          title: "Scheme #1",
        ),
      ]
    end

    let(:request_params) do
      {
        publishing_app: "specialist-publisher",
        document_type: "business_finance_support_scheme",
        order: "-last_edited_at",
        locale: "all",
        fields: %i[base_path content_id locale last_edited_at title publication_state state_history],
        page: 1,
        per_page: 1,
      }
    end

    it "returns all documents without organisation filter or search query" do
      request = stub_publishing_api_has_content(documents, request_params)

      response = subject.all(1, 1, nil, "business_finance_support_scheme", nil)

      expect(request).to have_been_requested
      expect(response["results"].length).to eq(1)
      expect(response["results"][0]["title"]).to eq "Scheme #1"
    end

    it "returns all documents from all organisations" do
      request = stub_publishing_api_has_content(documents, request_params)

      response = subject.all(1, 1, nil, "business_finance_support_scheme", "all")

      expect(request).to have_been_requested
      expect(response["results"].length).to eq(1)
      expect(response["results"][0]["title"]).to eq "Scheme #1"
    end

    it "returns all documents with search and organisation filter" do
      request_params[:q] = "Scheme"
      request_params[:link_organisations] = "12345"
      request = stub_publishing_api_has_content(documents, request_params)

      response = subject.all(1, 1, "Scheme", "business_finance_support_scheme", "12345")

      expect(request).to have_been_requested
      expect(response["results"].length).to eq(1)
      expect(response["results"][0]["title"]).to eq "Scheme #1"
    end
  end

  describe ".find_each" do
    it "does not yield anything if the publishing api response is empty" do
      publishing_api_has_no_content(BusinessFinanceSupportScheme)

      found_docs = []
      subject.find_each(BusinessFinanceSupportScheme) do |doc|
        found_docs << doc
      end

      expect(found_docs.length).to eq(0)
    end

    it "yields each document from the publishing api response" do
      documents = [
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/1",
          title: "Scheme #1",
        ),
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/2",
          title: "Scheme #2",
        ),
      ]
      stub_publishing_api_has_content(documents, hash_including(document_type: BusinessFinanceSupportScheme.document_type, page: "1"))

      found_docs = []
      subject.find_each(BusinessFinanceSupportScheme) do |doc|
        found_docs << doc
      end

      expect(found_docs.length).to eq(2)
      expect(found_docs[0]).to be_a BusinessFinanceSupportScheme
      expect(found_docs[0].title).to eq "Scheme #1"
      expect(found_docs[1]).to be_a BusinessFinanceSupportScheme
      expect(found_docs[1].title).to eq "Scheme #2"
    end

    it "fetches each page of documents and yields all of them" do
      documents = [
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/1",
          title: "Scheme #1",
        ),
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/2",
          title: "Scheme #2",
        ),
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/3",
          title: "Scheme #3",
        ),
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/4",
          title: "Scheme #4",
        ),
      ]
      pagination_calls = publishing_api_paginates_content(documents, 2, BusinessFinanceSupportScheme)

      found_docs = []
      subject.find_each(BusinessFinanceSupportScheme) do |doc|
        found_docs << doc
      end

      # 1. assert that we got all the docs
      expect(found_docs.length).to eq(4)

      expect(found_docs[0]).to be_a BusinessFinanceSupportScheme
      expect(found_docs[0].title).to eq "Scheme #1"
      expect(found_docs[1]).to be_a BusinessFinanceSupportScheme
      expect(found_docs[1].title).to eq "Scheme #2"

      expect(found_docs[2]).to be_a BusinessFinanceSupportScheme
      expect(found_docs[2].title).to eq "Scheme #3"
      expect(found_docs[3]).to be_a BusinessFinanceSupportScheme
      expect(found_docs[3].title).to eq "Scheme #4"

      # 2. assert that this wasn't the result of a single api call
      expect(pagination_calls.length).to eq(2)
      pagination_calls.each do |pagination_call|
        expect(pagination_call).to have_been_requested
      end
    end

    it "respects the query parameter if provided and sends it to publishing api when fetching documents" do
      documents = [
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/1",
          title: "Scheme #1",
        ),
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: "/bfss/2",
          title: "Scheme #2",
        ),
      ]
      pagination_calls_with_search = publishing_api_paginates_content(documents, 1, BusinessFinanceSupportScheme, search_query: "hats")

      subject.find_each(BusinessFinanceSupportScheme, query: "hats") { |x| x }

      pagination_calls_with_search.map do |pagination_call_without_search|
        expect(pagination_call_without_search).to have_been_requested
      end
    end
  end

  # NOTE: we do this manually because the stub_publishing_api_has_content test helper
  # is too restrictive and we can't properly control pagination
  def publishing_api_paginates_content(content_items, per_page, document_klass, search_query: nil)
    total_pages = content_items.length / per_page
    total_pages += 1 unless content_items.length.remainder(per_page).zero?
    if total_pages.zero?
      publishing_api_has_no_content(document_klass, search_query)
    else
      content_items.each_slice(per_page).with_index.map do |page_items, index|
        body = {
          results: page_items,
          total: content_items.length,
          pages: total_pages,
          current_page: index + 1,
        }
        query_params = {
          page: (index + 1).to_s,
          document_type: document_klass.document_type,
        }
        query_params[:q] = search_query if search_query.present?

        stub_request(:get, "#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}/content")
          .with(query: hash_including(query_params))
          .to_return(status: 200, body: body.to_json, headers: {})
      end
    end
  end

  def publishing_api_has_no_content(document_klass, search_query: nil)
    body = {
      results: [],
      total: 0,
      pages: 0,
      current_page: 1,
    }
    query_params = {
      page: "1",
      document_type: document_klass.document_type,
    }
    query_params[:query] = search_query if search_query.present?

    stub_request(:get, "#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}/content")
      .with(query: hash_including(query_params))
      .to_return(status: 200, body: body.to_json, headers: {})
  end
end
