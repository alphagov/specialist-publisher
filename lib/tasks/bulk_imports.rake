namespace :bulk_imports do
  desc "Import and publish Protected Food and Drink names.\n" \
    "Usage: bundle exec rake " \
    "bulk_imports:protected_food_and_drink_names\[spec/support/csvs/spirits_for_import_broken.csv\]"
  task :protected_food_and_drink_names, [:file_path] => :environment do |_, args|
    require "importers/protected_food_drink_name/service"

    errors_reported = 0
    imported_count = 0
    total_count = 0

    CSV.foreach(args.file_path, headers: true, skip_blanks: true, converters: ->(f) { f&.strip }).with_index do |row, index|
      next if row.all?(&:blank?)

      total_count += 1
      result = Importers::ProtectedFoodDrinkName::Service.call(row)

      if result.successful?
        imported_count += 1
      else
        errors_reported += 1

        puts "ERROR - Document index: #{index + 1}. #{result.error}"
      end
    end

    if errors_reported.zero?
      puts "No errors reported. #{imported_count} records imported."
    else
      puts "#{imported_count} out of #{total_count} records imported. " \
        "#{errors_reported} errors reported"
    end
  end
end
