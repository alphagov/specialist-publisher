namespace :permissions do
  desc "Grant a user 'gds_editor' and 'view_all' permissions"
  task :grant, [:name] => :environment do |_, args|
    user = User.where(name: args.name).first
    user.permissions |= %w(gds_editor)
    user.save
  end
end
