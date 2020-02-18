class NotificationsMailer < ApplicationMailer
  def document_list(url, user, document_klass, query)
    @url = url
    @user = user
    @document_klass = document_klass
    @query = query
    mail to: user.email, subject: "Your exported list of #{document_klass.title.pluralize} from GOV.UK"
  end
end
