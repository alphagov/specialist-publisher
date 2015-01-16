require "formatters/abstract_document_publication_alert_formatter"

class MedicalSafetyAlertPublicationAlertFormatter < AbstractDocumentPublicationAlertFormatter

  def name
    "Alerts and recalls for drugs and medical devices"
  end

  def body
    view_renderer.render(
      template: "email_alerts/medical_safety_alerts/publication",
      formats: ["html"],
      locals: html_body_local_assigns
    )
  end

  def subject
    if document.alert_type == "drugs"
      "Drug alert: #{document.title}"
    elsif document.alert_type == "devices"
      "Medical device alert: #{document.title}"
    else
      document.title
    end
  end

private
  def document_noun
    "alert"
  end

  def urgent
    true
  end

end
