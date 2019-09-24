FinderSignupLinksPresenter = Struct.new(:file) do
  def to_json(*_args)
    {
      content_id: file.fetch("signup_content_id"),
      links: {
        organisations: organisations,
        related: related,
      },
    }
  end

private

  def organisations
    file.fetch("organisations", [])
  end

  def related
    [file.fetch("content_id")]
  end
end
