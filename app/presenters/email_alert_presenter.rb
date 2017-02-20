class EmailAlertPresenter
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def to_json
    {
      subject: subject,
      body: body,
      tags: tags,
      urgent: urgent,
      document_type: document.document_type,
    }.merge(extra_options)
  end

private

  def body
    if document.document_type == "medical_safety_alert"
      standard_body("email_alerts/medical_safety_alerts/publication")
    else
      standard_body("email_alerts/publication")
    end
  end

  # The tags are sent to email-alert-api and matched against subscriberlists.
  def tags
    {
      # This format should be the same as https://github.com/alphagov/finder-frontend/blob/2c1d5f25e7e4212795b485b6e4c290c6764c813c/app/controllers/email_alert_subscriptions_controller.rb#L41
      format: document.search_document_type
    }.deep_merge(document.format_specific_metadata.reject { |_k, v| v.blank? })
  end

  def standard_body(template_path)
    view_renderer.render(
      template: template_path,
      formats: ["html"],
      locals:   {
        document_title: document.title,
        document_summary: document.summary,
        document_url: File.join(Plek.current.website_root, document.base_path),
        document_change_note: document.change_note,
        document_org_title: org_title[document.document_type],
        document_noun: document_noun[document.document_type],
        updated_or_published: updated_or_published,
      }
    )
  end

  def org_title
    {
      "aaib_report" => "Air Accidents Investigation Branch reports",
      "asylum_support_decision" => "Asylum Support Decision",
      "business_finance_support_scheme" => "Business finance support scheme",
      "cma_case" => "Competition and Markets Authority cases",
      "countryside_stewardship_grant" => "Countryside Stewardship Grants",
      "employment_appeal_tribunal_decision" => "Employment appeal tribunal decisions",
      "employment_tribunal_decision" => "Employment tribunal decisions",
      "esi_fund" => "European Structural and Investment Funds",
      "international_development_fund" => "International Development Funds",
      "maib_report" => "Marine Accident Investigation Branch reports",
      "medical_safety_alert" => "Alerts and recalls for drugs and medical devices",
      "raib_report" => "Rail Accident Investigation Branch reports",
      "tax_tribunal_decision" => "Upper Tribunal (Tax and Chancery Chamber)",
      "utaac_decision" => "Upper Tribunal (Administrative Appeals Chamber)",
      "vehicle_recalls_and_faults_alert" => "Vehicle recalls and faults",
    }
  end

  def document_noun
    {
      "aaib_report" => "report",
      "asylum_support_decision" => "decision",
      "business_finance_support_scheme" => "scheme",
      "cma_case" => "case",
      "countryside_stewardship_grant" => "grant",
      "employment_appeal_tribunal_decision" => "decision",
      "employment_tribunal_decision" => "decision",
      "esi_fund" => "fund",
      "international_development_fund" => "fund",
      "maib_report" => "report",
      "medical_safety_alert" => "alert",
      "raib_report" => "report",
      "tax_tribunal_decision" => "decision",
      "utaac_decision" => "decision",
      "vehicle_recalls_and_faults_alert" => "alert",
    }
  end

  def subject
    redrafted? ? document.title + " updated" : document.title
  end

  def urgent
    document.urgent
  end

  def updated_or_published
    redrafted? ? "updated" : "published"
  end

  def redrafted?
    document.draft? && !document.first_draft?
  end

  def extra_options
    {
      header: header,
      footer: footer,
    }.reject { |_k, v| v.nil? }
  end

  def view_renderer
    ActionView::Base.new(Rails.root.join("app/views"))
  end

  def header
    view_renderer.render(
      template: "email_alerts/publication_header",
      formats: ["html"],
    )
  end

  def footer
    view_renderer.render(
      template: "email_alerts/publication_footer",
      formats: ["html"],
    )
  end
end
