desc "Apply tagging rules to all content"
task :auto_tagging, [:do_tag] => :environment do |_, args|
  DocumentsTagger.tag_all(do_tag: args.do_tag == "tag").each do |result|
    puts "#{result[:base_path]} (#{result[:content_id]}) - #{result[:taxons].join(', ')}" unless result[:taxons].empty?
  end
end
