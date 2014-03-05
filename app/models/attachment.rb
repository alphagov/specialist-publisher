require 'attachable'

class Attachment
  include Mongoid::Document
  include Attachable

  field :title, type: String
  field :filename, type: String
  attaches :file

  embedded_in :specialist_document_edition
end
