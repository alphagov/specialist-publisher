# Preview all emails at http://localhost:3000/rails/mailers/notifications
class NotificationsPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notifications/document_list_without_query
  def document_list_without_query
    csv = "Header one,Header two\nrow a value one,row a value two\nrow b value one,row b value two\n"
    NotificationsMailer.document_list(csv, User.first, BusinessFinanceSupportScheme, nil)
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications/document_list_with_query
  def document_list_with_query
    csv = "Header one,Header two\nrow a value one,row a value two\nrow b value one,row b value two\n"
    NotificationsMailer.document_list(csv, User.first, BusinessFinanceSupportScheme, "startups")
  end
end
