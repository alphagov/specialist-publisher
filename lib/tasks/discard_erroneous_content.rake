desc "Discard drafts for content ids that mismatch with Publishing API"
task discard_erroneous: :environment do
  erroneous_content_ids = %w(
    60202834-a0d0-46b0-9925-6e2c2b933603
    9136e4f3-5f4c-4ce0-b4a3-eaf1b8e00a63
    95f0b6ef-6fc8-407c-845a-41f5ebd38537
    a16733e8-be43-4e1d-8589-37c066c4531e
    c24d7d3d-fba6-4769-aa84-ad30f31e8fa8
    c8436e13-21b8-4de9-b13d-59b299e74a27
    ce37764b-c7f3-4771-b614-2de275353ae0
    faf7b1e4-a0c1-4438-894f-39148676e289
  )

  erroneous_content_ids.each do |content_id|
    document = Document.find(content_id)
    document.discard

    puts "Discarded #{content_id}, #{document.state_history.inspect}"
  end
end
