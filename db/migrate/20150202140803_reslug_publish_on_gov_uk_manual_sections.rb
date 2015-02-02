# The history
# ===========
#
# Until now it's not been possible for editors to reorder sections in a manual.
# It's still not possible for editors to remove sections from a manual.
#
# To work around these limitations, editors have been copy-pasting content
# around, reusing old sections to get the correct ordering. Unfortunately, the
# slug of a section is never updated after it's been published, so many of the
# slugs are now very wrong. The version history for these sections is also
# wrong because it includes content from different sections.
#
# This migration addresses those issues in the "How to publish on GOV.UK"
# manual.
#
# What we've got
# ==============
#
# Section ID: 6106222c-d5af-41d1-a021-69fff7b9ef88
# Section slug: feedback
#
# 1 edition for "Feedback"
# 1 edition for "Topical Event Pages"
#
# Section ID: 03e40675-3c0f-41d6-8f20-63a1196b52f5
# Section slug: -feedback
#
# 1 edition for "Feedback"
#
# What we want
# ============
#
# Section ID: <needs to be generated>
# Section slug: topical-event-pages
#
# 1 edition for "Topical Event Pages"
# - 1 edition from -feedback
#
# Section ID: 6106222c-d5af-41d1-a021-69fff7b9ef88
# Section slug: feedback
#
# 2 editions for "Feedback"
# - 1 edition from feedback
# - 1 edition from -feedback
#
# How we get there
# ================
#
# 1.  Create a new `document_id` for the slug topical-event-pages. Move the
#     "Topical Event Pages" edition from feedback to it.
#
# 2.  Move the "Feedback" edition from -feedback to feedback (update
#     document_id, slug)
#
# 3.  Make sure all of the documents are in the right order.
#
# 4.  Add a redirect to router-data for -feedback to feedback

require "securerandom"

class ReslugPublishOnGovUkManualSections < Mongoid::Migration
  def self.up
    manual_id = "2606097c-e82a-4f5d-920a-5f360dcff626"

    feedback_id = "6106222c-d5af-41d1-a021-69fff7b9ef88"
    feedback_slug = "guidance/how-to-publish-on-gov-uk/feedback"

    topical_event_pages_id = SecureRandom.uuid
    topical_event_pages_slug = "guidance/how-to-publish-on-gov-uk/topical-event-pages"

    hyphen_feedback_id = "03e40675-3c0f-41d6-8f20-63a1196b52f5"
    hyphen_feedback_slug = "guidance/how-to-publish-on-gov-uk/-feedback"

    # Create a new document for "Topical Event Pages" edition, and move it onto
    # it
    move_edition_to_document(
      original_document_id: feedback_id,
      original_version_number: 2,
      new_document_id: topical_event_pages_id,
      new_version_number: 1,
      new_slug: topical_event_pages_slug,
    )

    # Move the "Feedback" edition from the -feedback document
    move_edition_to_document(
      original_document_id: hyphen_feedback_id,
      original_version_number: 1,
      new_document_id: feedback_id,
      new_version_number: 2,
      new_slug: feedback_slug,
    )

    # Get the most recent edition of the manual and set the document_ids to be
    # in the correct order and to not include the (now defunct) -feedback
    # edition
    manual_record = ManualRecord.where(
      manual_id: manual_id,
    ).first

    latest_manual_edition = manual_record.editions.last

    new_document_order = [
      "daed0b94-9ca1-4658-86d5-a53c614949f6",
      "ab0998b9-ecec-47bf-9bdf-0584cf1ccd85",
      "1e79de69-1f19-4e79-bb4c-908152415cce",
      "f4372e72-43ef-48bf-b557-74c0892c466f",
      "1ed295a8-d10f-40f2-b399-00126d0d8430",
      "41c3cfb7-d4f8-4121-aafd-1fc74acf2b9f",
      "7a9ed326-fdd9-402f-b078-0c46e83f547c",
      "60f94a7d-1e84-4c30-bcc0-eb266869f56e",
      "e4b840f9-64f2-4cef-b71f-9597ec19a659",
      "173903e4-10da-4d01-90d5-52d7c4c70e8f",
      "29f3ad1d-529c-49f3-acf3-bec02db94591",
      "8effda64-7f9c-419a-b27d-18a8629ca2dd",
      "f3ce0514-db9c-4611-ba0f-1ea6a5a751d9",
      "f7156084-9328-4226-a5a5-b1a555364211",
      "d7bf5fc5-92a7-4d9a-95e8-d359399f8b01",
      topical_event_pages_id,
      feedback_id,
    ]

    latest_manual_edition.set(:document_ids, new_document_order)
  end

  def self.move_edition_to_document(original_document_id:,
                                    original_version_number:,
                                    new_document_id:,
                                    new_version_number:,
                                    new_slug: nil)
    edition = SpecialistDocumentEdition.where(
      document_id: original_document_id,
      version_number: original_version_number,
    ).first

    original_slug = edition.slug

    # Using `set` here prevents timestamps being modified
    edition.set(:document_id, new_document_id)
    edition.set(:version_number, new_version_number)
    edition.set(:slug, new_slug) if new_slug.present?

    # Update any publication logs for this edition
    publication_logs = PublicationLog.where(
      slug: original_slug,
      version_number: original_version_number,
    )

    publication_logs.each do |log|
      log.set(:slug, new_slug) if new_slug.present?
      log.set(:version_number, new_version_number)
    end
  end

  def self.down
    # Whilst it would be possible to reverse this, it would be a lot of work
    # for something that is unlikely to ever get run.
    raise IrreversibleMigration
  end
end
