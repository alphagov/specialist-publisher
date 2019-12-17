revision_file = Rails.root.join("REVISION")
if File.exist?(revision_file)
  revision = File.read(revision_file).strip
  CURRENT_RELEASE_SHA = revision[0..10] # Just get the short SHA
else
  CURRENT_RELEASE_SHA = "development".freeze
end
