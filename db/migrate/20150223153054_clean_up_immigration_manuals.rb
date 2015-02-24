class CleanUpImmigrationManuals < Mongoid::Migration
  def self.up
    ids_of_manuals_to_remove = [
      "7ba1ed88-a33f-4688-b398-b31fa9591133", # Immigration Rules - Test 1
      "be1335e0-6267-4183-9988-3a1afdbcb160", # Immigration Rules - Test 2
    ]

    ids_of_manuals_to_remove.each do |manual_id|
      delete_manual(manual_id)
    end

    reslug_manual(
      manual_id: "87e2748f-2e9b-4681-8baa-778b6d326a8a", # Immigration Rules
      new_manual_slug: "guidance/immigration-rules",
    )
  end

  def self.delete_manual(manual_id)
    puts "Deleting manual: #{manual_id}"

    manual_record = ManualRecord.where(manual_id: manual_id).first
    slug_matcher = manual_slug_matcher(manual_record.slug)

    # Delete all the publication logs
    logs = PublicationLog.where(slug: slug_matcher)

    puts "  deleting #{logs.count} PublicationLog records"
    logs.destroy_all

    # Delete all the manual sections
    manual_section_document_ids = manual_record
                                    .editions
                                    .flat_map(&:document_ids)
                                    .uniq

    sections = SpecialistDocumentEdition.where(
      :document_id.in => manual_section_document_ids
    )

    puts "  deleting #{sections.count} SpecialistDocumentEdition records"
    sections.destroy_all

    # Delete the manual itself
    puts "  deleting the ManualRecord"
    manual_record.destroy
  end

  def self.reslug_manual(manual_id:, new_manual_slug:)
    puts "Reslugging manual: #{manual_id}"

    manual_record = ManualRecord.where(manual_id: manual_id).first
    slug_matcher = manual_slug_matcher(manual_record.slug)

    puts "  moving from #{manual_record.slug} to #{new_manual_slug}"

    # Reslug all the publication logs
    logs = PublicationLog.where(slug: slug_matcher)

    puts "  reslugging #{logs.count} PublicationLog records"
    logs.each do |log|
      new_slug = log.slug.sub(slug_matcher, new_manual_slug)

      puts "    #{log.slug} => #{new_slug}"
      log.update_attribute(:slug, new_slug)
    end

    # Reslug all the manual sections
    manual_section_document_ids = manual_record
                                    .editions
                                    .flat_map(&:document_ids)
                                    .uniq

    sections = SpecialistDocumentEdition.where(
      :document_id.in => manual_section_document_ids
    )

    puts "  reslugging #{sections.count} SpecialistDocumentEdition records"
    sections.each do |section|
      new_slug = section.slug.sub(slug_matcher, new_manual_slug)

      puts "    #{section.slug} => #{new_slug}"
      section.update_attribute(:slug, new_slug)
    end

    # Reslug the manual itself
    puts "  reslugging the ManualRecord"
    manual_record.update_attribute(:slug, new_manual_slug)
  end

  # Returns a regex to match slugs the belong to a manual, ie:
  #
  #   matcher = manual_slug_matcher("guidance/a-manual")
  #
  #   matcher =~ "guidance/a-manual" # => true
  #   matcher =~ "guidance/a-manual/a-section" # => true
  #   matcher =~ "guidance/a-manual-guide" # => false
  #   matcher =~ "guidance/a-manual-guide/a-section" # => false
  #
  #   "guidance/a-manual/a-section".sub(matcher, "another-slug")
  #     # => "another-slug/a-section"
  #
  def self.manual_slug_matcher(manual_slug)
    %r{\A#{manual_slug}(?=/|\z)}
  end

  def self.down
    raise IrreversibleMigration
  end
end
