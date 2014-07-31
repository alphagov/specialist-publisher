require "delegate"

class ChangeNoteValidator < SimpleDelegator
  def initialize(entity)
    @entity = entity
    reset_errors
    super(entity)
  end

  def valid?
    reset_errors
    entity_valid = entity.valid?
    change_note_ok = (change_note_not_required? || change_note_provided?)

    entity_valid && change_note_ok
  end

  def errors
    entity.errors.to_hash.merge(@errors)
  end

  private

  attr_reader :entity

  def change_note_not_required?
    never_published? || minor_update?
  end

  def never_published?
    !entity.published?
  end

  def change_note_provided?
    if change_note.present?
      true
    else
      add_errors
      false
    end
  end

  def reset_errors
    @errors = {}
  end

  def add_errors
    @errors[:change_note] ||= []
    @errors[:change_note].push(change_note_error)
  end

  def change_note_error
    "You must provide a change note or indicate minor update"
  end
end
