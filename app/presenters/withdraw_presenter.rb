class WithdrawPresenter
  def initialize(content_id, base_path)
    @content_id = content_id
    @base_path = base_path
  end

  def to_json
    {
      content_id: content_id,
      base_path: base_path,
      document_type: "gone",
      schema_name: "gone",
      format: "gone",
      publishing_app: "specialist-publisher",
      routes: [
        {
          path: base_path,
          type: "exact",
        }
      ]
    }
  end

private

  attr_reader :content_id, :base_path
end
