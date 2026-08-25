# This app has no database - see app/models/user.rb for why. Insert our
# own middleware immediately before Warden::Manager (added by gds-sso) so
# that Current has this request's session ready before Warden asks
# User.where to rebuild the signed-in user from it.
#
# We require the file explicitly, rather than relying on Zeitwerk to
# autoload the bare SpecialistPublisherUserSession constant: Rails doesn't
# finish wiring up autoloading until its "finisher" initializers run,
# which happens after every file in config/initializers has already
# loaded, and (in Rails 8.1) the middleware stack doesn't support passing
# a not-yet-loaded class as a string either - it calls .new on whatever
# it's given at build time. Requiring the file directly here sidesteps
# the whole autoloading timing question.
require Rails.root.join("app/middleware/specialist_publisher_user_session")

Rails.application.config.middleware.insert_before Warden::Manager, SpecialistPublisherUserSession
