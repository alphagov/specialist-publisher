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
end
