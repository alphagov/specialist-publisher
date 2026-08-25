# This app has no database (see app/models/user.rb for why), so the
# signed-in user's full details have to travel in the session cookie
# rather than being looked up from a Users table on every request.
#
# This middleware just makes that request's session available to Current
# before Warden gets a chance to ask User.where to rebuild the signed-in
# user from it. It's inserted immediately before Warden::Manager in
# config/application.rb, which guarantees:
#
# * it runs after ActionDispatch::Session::CookieStore, so
#   env["rack.session"] is already populated from the cookie; and
# * it runs before anything that might ask Warden for the current user
#   (gds-sso's Warden::Manager.serialize_from_session hook, which calls
#   User.where, and the mock/real sign-in strategies).
class SpecialistPublisherUserSession
  def initialize(app)
    @app = app
  end

  def call(env)
    Current.session = env["rack.session"]
    @app.call(env)
  ensure
    Current.reset
  end
end
