# Per-request home for the Rack session, so that User (which has no
# database to query) can rehydrate the signed-in user from the session
# cookie inside a plain class method call - see User.where and
# User#clear_remotely_signed_out!.
#
# Populated by SpecialistPublisherUserSession on every request.
class Current < ActiveSupport::CurrentAttributes
  attribute :session

  # The full user snapshot stashed in the session, if any - see
  # User#attributes and #persist below.
  def user_attrs
    session && session["specialist_publisher_user"]
  end

  # Stash a fresh snapshot of +user+ in the session, so subsequent
  # requests in this browser session can rebuild the same user without a
  # database - see User.where.
  def persist(user)
    session["specialist_publisher_user"] = user.attributes if session
  end
end
