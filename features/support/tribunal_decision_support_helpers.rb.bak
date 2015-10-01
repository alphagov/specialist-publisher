module TribunalDecisionHelpers

  def tribunal_decision_type(value)
    type = value.singularize.underscore.gsub(' ','_').to_sym
  end

  def tribunal_decision_path(documents)
    types = tribunal_decision_type(documents).to_s.pluralize
    send(:"#{types}_path")
  end

  def tribunal_decision_fields(type, overrides)
    fields = {
      title: "Lorem ipsum",
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10)
    }
    fields.merge!(tribunal_decision_fields_for(type))
    fields.merge!(overrides)
    fields
  end

  def create_tribunal_decision(type, overrides = {})
    fields = tribunal_decision_fields(type, overrides)
    create_document(type, fields)
  end

  def tribunal_decision_fields_for(type)
    case type
    when :asylum_support_decision
      {
        "Category" => "Section 95 (asylum-seekers)",
        "Sub-category" => "Section 95 - jurisdiction",
        "Judges" => "Bashir, S",
        "Decision date" => "2015-02-02",
        "Landmark" => "Landmark",
        "Reference number" => "1234"
      }
    when :utaac_decision
      {
        "Category" => "Benefits for children",
        "Sub-category" => "Benefits for children - child benefit",
        "Judges" => "Angus, R",
        "Decision date" => "2015-02-02"
      }
    else
      raise "Add fields for #{type} to tribunal_decision_fields_for() in tribunal_decision_helpers.rb"
    end
  end
end
