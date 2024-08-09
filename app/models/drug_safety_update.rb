class DrugSafetyUpdate < Document
  def self.title
    "Drug Safety Update"
  end

  def send_email_on_publish?
    false
  end
end
