require "attachable"

class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Attachable

  field :title
  field :filename
  attaches :file, with_url_field: true, update_existing: true

  embedded_in :specialist_document_edition

  def to_param
    id
  end

  def snippet
    "[InlineAttachment:#{filename}]"
  end
end
