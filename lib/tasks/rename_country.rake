namespace :rename_country do
  desc "Update and republish all docs that refer to a country"
  task :all, [:old, :new] => :environment do |_t, args|
    Rake::Task["rename_country:export_health_certificates"].invoke(*args)
    Rake::Task["rename_country:international_development_funds"].invoke(*args)
  end

  desc "Update and republish export health certificates that refer to a country"
  task :export_health_certificates, [:old, :new] => :environment do |_t, args|
    ExportHealthCertificate.find_each do |doc|
      current_value = doc.destination_country
      next unless current_value&.include? args[:old]

      RepublishService.new.call(doc.content_id, doc.locale) do |payload|
        new_value = current_value - [args[:old]] + [args[:new]]
        payload[:details][:metadata][:destination_country] = new_value
      end
    end
  end

  desc "Update and republish international development funds that refer to a country"
  task :international_development_funds, [:old, :new] => :environment do |_t, args|
    InternationalDevelopmentFund.find_each do |doc|
      current_value = doc.location
      next unless current_value&.include? args[:old]

      RepublishService.new.call(doc.content_id, doc.locale) do |payload|
        new_value = current_value - [args[:old]] + [args[:new]]
        payload[:details][:metadata][:location] = new_value
      end
    end
  end
end
