class ChangeNoteValidator < SimpleDelegator
  def initialize(entity)
    @entity = entity
    @errors = {}
    super(entity)
  end

  def valid?
    (change_note_provided_or_minor_update? && entity.valid?)
  end

  def errors
    entity.errors.merge(@errors)
  end

  private

  attr_reader :entity

  def change_note_provided_or_minor_update?
    if change_note.present? || minor_update?
      result = true
    else
      result = false
      @errors[:change_note] ||= []
      @errors[:change_note].push(change_note_error)
    end

    result
  end

  def change_note_error
    "You must provide a change note or indicate minor update"
  end
end
