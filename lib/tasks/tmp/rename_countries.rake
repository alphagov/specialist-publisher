namespace :tmp do
  desc "Republish finders and rename countries"
  task rename_countries: :environment do
    run_task = lambda do |name, *args|
      task = Rake::Task[name]
      task.reenable
      task.invoke(*args)
    end

    run_task.call("publishing_api:publish_finder", "export_health_certificates")
    run_task.call("publishing_api:publish_finder", "international_development_funds")
    run_task.call("publishing_api:publish_finder", "research_for_development_outputs")

    run_task.call("rename_country:all", "nauru", "naoero")
    run_task.call("rename_country:all", "bonaire-st-eustatius-saba", "bonaire-sint-eustatius-saba")
    run_task.call("rename_country:all", "st-maarten", "sint-maarten")
    run_task.call("rename_country:all", "bahamas", "the-bahamas")
  end
end
