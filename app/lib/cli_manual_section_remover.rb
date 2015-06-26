class CliManualSectionRemover
  def initialize(manual_id:, section_id:, options: {})
    @manual_id = manual_id
    @section_id = section_id
    @stdin = options.fetch(:stdin, STDIN)
    @stdout = options.fetch(:stdout, STDOUT)
    @stderr = options.fetch(:stderr, STDERR)
  end

  def call
    manual, section = manual_and_section

    user_must_confirm(manual, section)

    services.remove(service_context).call

    manual_section_removed_success

  rescue RemoveManualDocumentService::PreviouslyPublishedError
    previously_published_error
  end

private
  attr_reader :manual_id, :section_id, :stdin, :stdout, :stderr

  def user_must_confirm(manual, section)
    stdout.puts confirmation_message(manual, section)

    no_user_confirmation_notice unless user_confirmed?
  end

  def user_confirmed?
    user_response == "Yes"
  end

  def user_response
    stdin.gets.strip
  end

  def confirmation_message(manual, section)
    %(
### PLEASE CONFIRM -------------------------------------
You want to remove the section '#{section.title}' from the manual '#{manual.title}'.
This manual was last edited at #{manual.updated_at} and belongs to #{manual.organisation_slug}.
Type 'Yes' to proceed and remove this manual section or type anything else to exit:
    )
  end

  def something_not_found_error
    stderr.puts something_not_found
    raise NotFoundError
  end

  def something_not_found
    "ERROR: We couldn't find the manual and/or section with those IDs."
  end

  def no_user_confirmation_notice
    stdout.puts no_user_confirmation
    raise NoUserConfirmation
  end

  def no_user_confirmation
    "NOTICE: Didn't receive a 'Yes' confirmation. Manual section was not removed."
  end

  def previously_published_error
    stderr.puts previously_published
    raise PreviouslyPublishedError
  end

  def previously_published
    "ERROR: This section has been published. Only draft manuals can be removed."
  end

  def manual_section_removed_success
    stdout.puts manual_section_removed
  end

  def manual_section_removed
    "SUCCESS: Manual section was removed."
  end

  def manual_and_section
    manual, section = services.show(service_context).call

    something_not_found_error if manual.nil? || section.nil?

    [manual, section]
  rescue KeyError
    something_not_found_error
  end

  def service_context
    OpenStruct.new(
      params: {
        "manual_id" => manual_id,
        "id" => section_id,
      },
    )
  end

  def services
    ManualDocumentServiceRegistry.new
  end

  class PreviouslyPublishedError < StandardError; end
  class NoUserConfirmation < StandardError; end
  class NotFoundError < StandardError; end
end
