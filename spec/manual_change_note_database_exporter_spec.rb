require "fast_spec_helper"

require "manual_change_note_database_exporter"

RSpec.describe ManualChangeNoteDatabaseExporter do
  subject(:exporter) {
    ManualChangeNoteDatabaseExporter.new(
      export_target: change_note_collection,
      publication_logs: publication_logs_collection,
      manual: manual,
    )
  }

  let(:change_note_collection) {
    double(:change_note_collection, :create_or_update_by_slug! => nil)
  }

  let(:manual_publication_logs) {
    [publication_log]
  }

  let(:publication_log) {
    double(
      :publication_log,
      slug: publication_log_slug,
      title: publication_log_title,
      change_note: publication_log_note,
      published_at: publication_log_timestamp,
    )
  }

  let(:publication_log_slug)        { double(:publication_log_slug) }
  let(:publication_log_title)       { double(:publication_log_title) }
  let(:publication_log_note)        { double(:publication_log_note) }
  let(:utc_publication_log_timestamp) { double(:utc_publication_log_timestamp) }
  let(:publication_log_timestamp)   { double(:publication_log_timestamp, utc: utc_publication_log_timestamp) }

  let(:publication_logs_collection) {
    double(:publication_logs_collection)
  }

  let(:manual) {
    double(
      :manual,
      slug: manual_slug,
      title: manual_title,
    )
  }

  let(:manual_slug) { "guidance/a-manual" }
  let(:manual_title) { double(:manual_title) }
  let(:change_note_slug) { "guidance/a-manual/updates" }

  describe "#call" do
    let(:scoped_collection) { double(:scoped_collection) }

    before do
      allow(publication_logs_collection).to receive(:change_notes_for)
        .and_return(manual_publication_logs)
    end

    it "retrieves the publication history for the manual" do
      exporter.call

      expect(publication_logs_collection).to have_received(:change_notes_for)
        .with(manual_slug)
    end

    it "upserts the change note record with change note and manual slug" do
      exporter.call

      expect(change_note_collection).to have_received(:create_or_update_by_slug!)
        .with(
          hash_including(
            slug: change_note_slug,
            manual_slug: manual_slug,
          )
        )
    end

    it "upserts the change note record with the updated change notes" do
      exporter.call

      expect(change_note_collection).to have_received(:create_or_update_by_slug!)
        .with(
          hash_including(
            updates: [
              {
                slug: publication_log_slug,
                title: publication_log_title,
                change_note: publication_log_note,
                published_at: utc_publication_log_timestamp,
              }
            ]
          )
        )
    end
  end
end
