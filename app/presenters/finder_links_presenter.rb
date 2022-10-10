FinderLinksPresenter = Struct.new(:file) do
  def to_json(*_args)
    {
      content_id: file.fetch("content_id"),
      links: {
        organisations:,
        related:,
        email_alert_signup:,
        parent:,
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

  def parent
    [file.fetch("parent", nil)].compact
  end
end
