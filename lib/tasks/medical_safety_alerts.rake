namespace :medical_safety_alerts do
  desc "Change type of medical alerts"
  task :change_alert_type, %i[old new] => :environment do |_, args|
    MedicalSafetyAlert.find_each do |doc|
      next unless doc.alert_type == args[:old]

      RepublishService.new.call(doc.content_id, doc.locale) do |payload|
        payload[:details][:metadata][:alert_type] = args[:new]
      end
    end
  end
end
