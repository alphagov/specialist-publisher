namespace :base_path do
  # This is equivalent to other Publishing applications' "reslugging" tasks.
  # Once run, it will create a new draft document with the new `base_path`. The published document remains at the old base_path at this point. Your edition is now in a "published with new draft" state.
  # To finish the reslug, you will need to publish the new draft document. This will cause the old document to redirect to the new base_path.
  # Pass `true` as the final argument to publish the new draft automatically and complete the reslug in one step.

  desc "Edits the base_path of a document, given its content_id and the new base_path"
  task :edit, %i[content_id locale new_base_path publish] => %i[environment] do |_t, args|
    document = Document.find(args[:content_id], args[:locale])
    old_base_path = document.base_path

    document.base_path = args[:new_base_path]
    document.update_type = "minor"
    abort "Failed to save: #{document.errors.full_messages.join(', ')}" unless document.save

    puts "#{old_base_path} -> #{document.base_path}"

    if args[:publish] == "true"
      abort "Failed to publish: #{document.errors.full_messages.join(', ')}" unless document.publish
      puts "Published #{document.base_path}"
    end
  end

  # Reslugs every document of a type so it sits under its finder's live base_path:
  # published documents are moved and re-published (the old path then redirects),
  # drafts are moved but kept in draft, and unpublished documents or ones already
  # under the finder's base_path are skipped. It prints a report of each outcome.
  #
  # Only runs when the finder is published to the live stack at the base_path in
  # its schema, so deploy the schema change and run publishing_api:publish_finder
  # first.
  desc "Reslugs a type's documents under its finder's live base_path (published redirect, drafts stay draft)"
  task :edit_all, %i[document_type] => %i[environment] do |_t, args|
    document_type = args[:document_type]
    shell = Thor::Shell::Basic.new
    finder_schema = FinderSchema.load_from_schema(document_type.pluralize)
    schema_base_path = finder_schema.base_path

    begin
      finder = Services.publishing_api.get_content(finder_schema.content_id).to_h
    rescue GdsApi::HTTPNotFound
      shell.say_error "The #{document_type} finder does not exist."
      next
    end

    unless finder["publication_state"] == "published"
      shell.say_error "The #{document_type} finder is not published to the live stack " \
                      "(currently #{finder['publication_state']}); this task only reslugs " \
                      "documents for finders on the live stack."
      next
    end

    unless finder["base_path"] == schema_base_path
      shell.say_error "The #{document_type} finder must be published at #{schema_base_path} " \
                      "before reslugging its documents (currently published at #{finder['base_path']})."
      next
    end

    message = <<~CONFIRMATION
      This will reslug every #{document_type} document to sit under #{schema_base_path}.
      Published documents are moved and re-published (redirecting the old path);
      documents with a draft are moved but kept in draft.
    CONFIRMATION

    unless shell.yes?("#{message}Proceed? (yes/no)")
      shell.say_error "Aborted"
      next
    end

    report = DocumentReslugger.new(document_type, schema_base_path).reslug_all

    puts report
  end
end
