require "ostruct"

# TODO: Remove this when content models are updated
# Also remove line from cucumber env
class RenderedSpecialistDocument < OpenStruct
  @store = {}

  def self.clear!
    @store = {}
  end

  def self.create(attrs)
    @store.store(attrs.fetch(:id), attrs)
  end

  class << self
    alias_method :create!, :create
  end

  def self.where(criteria)
    @store
      .select { |id, object_attrs|
        criteria.all? { |field_name, field_value|
          object_attrs[field_name] == field_value
        }
      }
      .map { |id, object_attrs|
        new(object_attrs)
      }
  end
end
