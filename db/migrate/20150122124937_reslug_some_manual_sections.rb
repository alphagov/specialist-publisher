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
# This migration addresses those issues in the "Support for government
# publishers" manual.
#
# Incidentally, the slug for the manual is now a bit inappropriate
# (contact-the-government-digital-service), but we aren't addressing that here.
#
# What we've got
# ==============
#
# Section ID: ae518361-b320-4e77-b745-f0c1051d314e
# Section slug: gov-uk-support-requests-processes-and-response-times
#
# 1 edition with placeholder content
# 3 editions for "National emergency publishing guidelines"
#
# Section ID: 4243d246-1b5c-410c-9dfa-90d861e67129
# Section slug: national-emergency-publishing-guidelines
#
# 1 edition for "National emergency publishing guidelines"
# 1 edition for "Feedback"
# 5 editions for "Help with content quality"
#
# Section ID: e2ad5bb1-4ef0-4799-9b8e-293b11a89f8d
# Section slug: feedback
#
# 1 edition for "Feedback"
#
# What we want
# ============
#
# Section ID: 4243d246-1b5c-410c-9dfa-90d861e67129
# Section slug: national-emergency-publishing-guidelines
#
# 4 editions for "National emergency publishing guidelines"
#   - 1 edition from national-emergency-publishing-guidelines
#   - 3 editions from gov-uk-support-requests-processes-and-response-times
#
# Section ID: <needs to be generated>
# Section slug: help-with-content-quality
#
# 5 editions for "Help with content quality"
#   - 5 editions from national-emergency-publishing-guidelines
#
# Section ID: e2ad5bb1-4ef0-4799-9b8e-293b11a89f8d
# Section slug: feedback
#
# 2 editions for "Feedback"
#   - 1 edition from national-emergency-publishing-guidelines
#   - 1 edition from feedback
#
# How we get there
# ================
#
# 1.  Move the "Feedback" edition from national-emergency-publishing-guidelines
#     to feedback (update document_id, update slug)
#
# 2.  Create a new `document_id` for the slug help-with-content-quality. Move
#     all the "Help with content quality" editions from
#     national-emergency-publishing-guidelines to it.
#
# 3.  Move the "National emergency publishing guidelines" edition from
#     gov-uk-support-requests-processes-and-response-times to
#     national-emergency-publishing-guidelines (update document_id, slug)
#
# 4.  Remove the gov-uk-support-requests-processes-and-response-times document
#     from the manual (drop it from `document_ids`)
#
# 5.  Update the slug on all of the affected publication logs.
#
# 6.  Make sure all of the documents are in the right order.
#
# 7.  Add a redirect to router-data for
#     gov-uk-support-requests-processes-and-response-times to
#     national-emergency-publishing-guidelines
#
#     This is a bit gross, but that has been the URL of this section for ages
#     so it's probably better than just redirecting to the manual root
#
#     It's also unfortunate that we can't redirect any of the other slugs,
#     because they'll be in active use still.

require "securerandom"

class ReslugSomeManualSections < Mongoid::Migration
  def self.up
    manual_id = "f6489e06-f349-4f31-b5b3-049ea66bfc60"

    support_processes_id = "ae518361-b320-4e77-b745-f0c1051d314e"
    support_processes_slug = "guidance/contact-the-government-digital-service/gov-uk-support-requests-processes-and-response-times"

    emergency_publishing_id = "4243d246-1b5c-410c-9dfa-90d861e67129"
    emergency_publishing_slug = "guidance/contact-the-government-digital-service/national-emergency-publishing-guidelines"

    content_quality_id = SecureRandom.uuid
    content_quality_slug = "guidance/contact-the-government-digital-service/help-with-content-quality"

    feedback_id = "e2ad5bb1-4ef0-4799-9b8e-293b11a89f8d"
    feedback_slug = "guidance/contact-the-government-digital-service/feedback"

    # Move the first "Feedback" edition onto the feedback document, changing
    # the current edition to be the latest version
    move_edition_to_document(
      original_document_id: feedback_id,
      original_version_number: 1,
      new_document_id: feedback_id,
      new_version_number: 2,
    )

    move_edition_to_document(
      original_document_id: emergency_publishing_id,
      original_version_number: 2,
      new_document_id: feedback_id,
      new_version_number: 1,
      new_slug: feedback_slug,
    )

    # Create a new document for the "Help with content quality" editions, and
    # move them onto it
    move_edition_to_document(
      original_document_id: emergency_publishing_id,
      original_version_number: 3,
      new_document_id: content_quality_id,
      new_version_number: 1,
      new_slug: content_quality_slug,
    )

    move_edition_to_document(
      original_document_id: emergency_publishing_id,
      original_version_number: 4,
      new_document_id: content_quality_id,
      new_version_number: 2,
      new_slug: content_quality_slug,
    )

    move_edition_to_document(
      original_document_id: emergency_publishing_id,
      original_version_number: 5,
      new_document_id: content_quality_id,
      new_version_number: 3,
      new_slug: content_quality_slug,
    )

    move_edition_to_document(
      original_document_id: emergency_publishing_id,
      original_version_number: 6,
      new_document_id: content_quality_id,
      new_version_number: 4,
      new_slug: content_quality_slug,
    )

    move_edition_to_document(
      original_document_id: emergency_publishing_id,
      original_version_number: 7,
      new_document_id: content_quality_id,
      new_version_number: 5,
      new_slug: content_quality_slug,
    )

    # Move the "National emergency publishing guidelines" editions onto the
    # national-emergency-publishing-guidelines document,
    move_edition_to_document(
      original_document_id: support_processes_id,
      original_version_number: 2,
      new_document_id: emergency_publishing_id,
      new_version_number: 2,
      new_slug: emergency_publishing_slug,
    )

    move_edition_to_document(
      original_document_id: support_processes_id,
      original_version_number: 3,
      new_document_id: emergency_publishing_id,
      new_version_number: 3,
      new_slug: emergency_publishing_slug,
    )

    move_edition_to_document(
      original_document_id: support_processes_id,
      original_version_number: 4,
      new_document_id: emergency_publishing_id,
      new_version_number: 4,
      new_slug: emergency_publishing_slug,
    )

    # Make a new edition of the manual and set the document_ids to be in the
    # correct order and to not include the (now defunct)
    # gov-uk-support-requests-processes-and-response-times edition
    manual_record = ManualRecord.where(
      manual_id: manual_id,
    ).first

    latest_manual_edition = manual_record.editions.last

    new_document_order = [
      "f6f24359-145a-4e6e-9e7e-d8107b32b156",
      "79499c22-67b8-4f27-81bf-8aa642c31165",
      "77f15a1e-e47c-471c-ad62-fd78bf6a7a33",
      emergency_publishing_id,
      content_quality_id,
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
