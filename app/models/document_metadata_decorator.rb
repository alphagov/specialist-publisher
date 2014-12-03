class DocumentMetadataDecorator < SimpleDelegator
  def initialize(document)
    @document = document
    super(document)
  end

  def update(attrs)
    extra_attrs = attrs.slice(*extra_field_names)

    data = attrs
      .except(*extra_field_names)
      .merge(extra_fields: document.extra_fields.merge(extra_attrs))

    document.update(data)
  end

  def attributes
    orig_attrs = document.attributes

    extra_attrs = orig_attrs.fetch(:extra_fields)

    orig_attrs
      .except(:extra_fields)
      .merge(extra_attrs)
  end

private
  def self.set_extra_field_names(field_names)
    all_fields = field_names + common_extra_fields
    @extra_field_names = all_fields

    all_fields.each do |field_name|
      define_method(field_name) do
        document.extra_fields.fetch(field_name, nil)
      end
    end
  end

  def self.extra_field_names
    @extra_field_names || []
  end

  def self.common_extra_fields
    [:bulk_published]
  end

  def extra_field_names
    self.class.extra_field_names
  end

  attr_reader :document
end
