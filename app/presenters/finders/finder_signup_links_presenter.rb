class FinderSignupLinksPresenter < Struct.new(:file)
  def to_json
    {
      content_id: file.fetch("signup_content_id"),
      links: {
        organisations: organisations,
        related: related,
      }
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
