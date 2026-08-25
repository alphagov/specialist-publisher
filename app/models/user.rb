# This app has no database. Signon (via the gds-sso gem) is the single
# source of truth for who a user is and what they can do, so this class
# never persists anything itself:
#
# * On sign-in (real Signon OAuth2 in production, or the local mock
#   strategy in development/test), gds-sso hands us a full snapshot of the
#   user's attributes and we just wrap it in a plain in-memory object -
#   see .find_for_gds_oauth and .first.
# * On every later request, gds-sso needs to rebuild that user from the
#   session alone (it only stores the uid + a timestamp itself). We keep
#   the full snapshot in the Rails session cookie itself (see Current and
#   SpecialistPublisherUserSession) and rehydrate it in .where.
#
# Trade-off: Signon's two "push" callbacks - PUT /auth/gds/api/users/:uid
# (instant permission updates) and POST /auth/gds/api/users/:uid/reauth
# (force remote sign-out) - have nowhere to persist to any more, so
# they're effectively inert now (they'll fail to authenticate anyway,
# since the API user they'd authenticate as was itself only ever a row in
# the table we've just removed). A user's permissions/disabled state now
# only refresh when they next sign in, or after `auth_valid_for` (20 hours)
# forces re-authentication - see GDS::SSO::Config.auth_valid_for.
class User
  include ActiveModel::Model
  include GDS::SSO::User

  ATTRIBUTE_NAMES = %i[
    uid
    email
    version
    name
    permissions
    organisation_slug
    organisation_content_id
    disabled
  ].freeze

  attr_accessor(*ATTRIBUTE_NAMES)
  attr_writer :remotely_signed_out

  # The single local user used to sign straight in when gds-sso is running
  # in mock mode (development, and test unless a spec sets
  # `GDS::SSO.test_user` itself).
  DEV_TEST_USER_ATTRIBUTES = {
    "uid" => "THISISMYUID",
    "name" => "Test user",
    "permissions" => %w[signin gds_editor],
    "organisation_content_id" => "af07d5a5-df63-4ddc-9383-6a666845ebe9",
  }.freeze

  def initialize(attributes = {})
    super
    @remotely_signed_out ||= false
  end

  def remotely_signed_out?
    !!@remotely_signed_out
  end

  def disabled?
    !!disabled
  end

  def gds_editor?
    has_permission?("gds_editor")
  end

  # Required by the "a gds-sso user class" lint (spec/models/user_spec.rb).
  def update_attribute(name, value)
    public_send(:"#{name}=", value)
    true
  end

  # Required by the "a gds-sso user class" lint. ActiveModel::Model gives us
  # #assign_attributes for free.
  def update!(attributes = {})
    assign_attributes(attributes)
    true
  end
  alias_method :update, :update!

  # There's nothing to save - FactoryBot's default :create strategy calls
  # this, and gds-sso's mock bearer token strategy calls it too.
  def save!
    true
  end
  alias_method :save, :save!

  # Called by gds-sso (via Warden::Manager.after_authentication) every time
  # this user successfully signs in. This is our one hook to stash the full
  # user snapshot in the session, since gds-sso itself only ever stores the
  # uid - see Current and SpecialistPublisherUserSession.
  def clear_remotely_signed_out!
    self.remotely_signed_out = false
    Current.persist(self)
    true
  end

  # Called by the (now effectively unreachable, see class comment above)
  # POST /auth/gds/api/users/:uid/reauth callback.
  def set_remotely_signed_out!
    self.remotely_signed_out = true
    Current.persist(self)
    true
  end

  # A plain, JSON-safe snapshot of this user. Used both to stash the user
  # in the session cookie (Current#persist) and to pass a user across a
  # Sidekiq job boundary (see DocumentListExportWorker), since neither has
  # a database row to hand a foreign key to instead.
  def attributes
    {
      "uid" => uid,
      "email" => email,
      "version" => version,
      "name" => name,
      "permissions" => permissions,
      "organisation_slug" => organisation_slug,
      "organisation_content_id" => organisation_content_id,
      "disabled" => disabled,
      "remotely_signed_out" => remotely_signed_out?,
    }
  end

  class << self
    # Used by the real Signon OAuth2 login strategy, and by the (real)
    # bearer-token strategy for API access - see gds-sso's
    # lib/gds-sso/warden_config.rb and lib/gds-sso/bearer_token.rb. Signon
    # has just told us everything about this user, so there's nothing to
    # look up or merge - we just build a fresh in-memory user from it.
    def find_for_gds_oauth(auth_hash)
      new(GDS::SSO::User.user_params_from_auth_hash(auth_hash.to_hash))
    end

    # Required by the "a gds-sso user class" lint. Not otherwise used,
    # since there's nothing to persist.
    def create!(attributes = {})
      new(attributes)
    end

    # Called by Warden (via Warden::Manager.serialize_from_session) on
    # every request to rebuild the signed-in user from their session.
    # We don't have a database to query, so we rehydrate from the full
    # snapshot that clear_remotely_signed_out! stashed in the session
    # cookie when they signed in - see Current.
    def where(conditions = {})
      attrs = Current.user_attrs
      return [] unless attrs && attrs["uid"] == conditions[:uid]&.to_s

      if conditions.key?(:remotely_signed_out) && !attrs["remotely_signed_out"].nil? != conditions[:remotely_signed_out]
        return []
      end

      [new(attrs)]
    end

    # Called by gds-sso's mock strategy (development, and test unless a
    # spec sets `GDS::SSO.test_user`) to sign someone in automatically,
    # without a login form.
    def first
      new(DEV_TEST_USER_ATTRIBUTES) if GDS::SSO::Config.use_mock_strategies?
    end
  end
end
