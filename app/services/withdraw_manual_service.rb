class WithdrawManualService
  def initialize(manual_repository:, listeners: [], manual_id:)
    @manual_repository = manual_repository
    @listeners = listeners
    @manual_id = manual_id
  end

  def call
    withdraw

    if manual.withdrawn?
      persist
      notify_listeners
    end

    manual
  end

private
  attr_reader :manual_repository, :listeners, :manual_id

  def withdraw
    manual.withdraw
  end

  def persist
    manual_repository.store(manual)
  end

  def notify_listeners
    listeners.each { |l| l.call(manual) }
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  rescue KeyError => error
    raise ManualNotFoundError.new(error)
  end

  class ManualNotFoundError < StandardError; end
end
