class AaibReport < SimpleDelegator
  def self.extra_field_names
    [
      :date_of_occurrence,
      :aircraft_category,
      :report_type,
    ]
  end

  extra_field_names.each do |field_name|
    define_method(field_name) do
      document.extra_fields.fetch(field_name, nil)
    end
  end

  def initialize(document)
    @document = document
    super(document)
  end

  def update(attrs)
    extra_attrs = attrs.slice(*extra_field_names)

    data = attrs
      .except(*extra_field_names)
      .merge(extra_fields: extra_attrs)

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
  def extra_field_names
    self.class.extra_field_names
  end

  attr_reader :document
end
