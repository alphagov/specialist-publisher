class FinderLinksPresenter < Struct.new(:file)
  def to_json
    {
      content_id: file.fetch("content_id"),
      links: {
        organisations: organisations,
        related: related,
        email_alert_signup: email_alert_signup,
      },
    }
  end

private

  def organisations
    file.fetch("organisations", [])
  end

  def related
    file.fetch("related", [])
  end

  def email_alert_signup
    [file.fetch("signup_content_id", nil)].compact
  end
end
