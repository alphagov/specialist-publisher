namespace :dev do
  desc "Ensure that a dev environment is setup correctly (create default user etc)"
  task :setup => :environment do
    logger = Logger.new(STDOUT)
    if User.count == 0
      logger.info "No users exist, creating test user..."
      u = User.new
      u.name = "Test User"
      u.email = "test.user@example.com"
      u.permissions = ["signin"]
      u.save!
      logger.info "User created. Yay!"
    else
      logger.info "A test user already exists"
    end

    logger.info ""
    logger.info "That's it! Everything should be working fine."
    logger.info "Now run all the tests using 'bundle exec rake'."
  end
end