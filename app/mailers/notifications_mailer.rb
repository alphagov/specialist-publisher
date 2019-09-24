class NotificationsMailer < ApplicationMailer
  def document_list(csv, user, document_klass, query)
    attachments["document_list.csv"] = csv

    @user = user
    @document_klass = document_klass
    @query = query
    mail to: user.email, subject: "Your exported list of #{document_klass.title.pluralize} from GOV.UK"
  end
end
