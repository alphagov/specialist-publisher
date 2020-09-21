namespace :base_path do
  desc "Edits the base_path of a document, given its content_id and the new base_path"
  task :edit, %i[content_id locale new_base_path] => %i[environment] do |_t, args|
    document = Document.find(args[:content_id], args[:locale])
    old_base_path = document.base_path

    document.base_path = args[:new_base_path]
    document.update_type = "minor"
    document.save

    puts "#{old_base_path} -> #{document.base_path}"
  end
end
