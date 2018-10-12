namespace :base_path do
  desc "Edits the base_path of a document, given its content_id and the new base_path"
  task :edit, [:content_id, :base_path] => [:environment] do |_t, args|
    content_id = args[:content_id]
    base_path = args[:base_path]

    begin
      document = Document.find(content_id)
    rescue DocumentFinder::RecordNotFound => e
      puts "Error finding the document: #{e.inspect}"
    end

    if document
      document.base_path = base_path
      document.update_type = 'minor'
      if document.save
        puts "The #{document.class} with title \"#{document.title}\" has been successfully edited"
        puts "Its new base_path is now \"#{document.base_path}\""
      else
        puts "Couldn't edit the #{document.class} with title \"#{document.title}\""
      end
    end
  end
end
