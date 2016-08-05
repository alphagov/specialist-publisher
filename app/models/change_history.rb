class ChangeHistory
  def self.parse(change_history_array)
    items = change_history_array.map do |item_hash|
      Item.new(
        public_timestamp: DateTime.parse(item_hash.fetch("public_timestamp")),
        change_note: item_hash.fetch("note")
      )
    end

    new(items)
  end

  def initialize(items = [])
    self.items = items
  end

  def size
    items.size
  end

  def as_json
    items.map do |item|
      {
        "public_timestamp" => item.public_timestamp.iso8601,
        "note" => item.change_note,
      }
    end
  end

  def first_published!
    if size > 0
      raise NonEmptyChangeHistoryError, "Change history must be empty to add the 'First published.' item"
    end

    add_item("First published.")
  end

  def add_item(change_note)
    items << Item.new(
      public_timestamp: Time.zone.now,
      change_note: change_note,
    )

    nil
  end

  def update_item(change_note)
    last_item = items.last

    unless last_item
      raise EmptyChangeHistoryError, "Change history must not be empty to update an item."
    end

    last_item.public_timestamp = Time.zone.now
    last_item.change_note = change_note

    nil
  end

  def latest_change_note
    items.last.change_note if size > 0
  end

  def ==(other)
    items == other.items
  end

protected

  attr_accessor :items

  class Item
    attr_accessor :public_timestamp, :change_note

    def initialize(public_timestamp:, change_note:)
      self.public_timestamp = public_timestamp
      self.change_note = change_note
    end

    def ==(other)
      public_timestamp == other.public_timestamp &&
        change_note == other.change_note
    end
  end

  class ::EmptyChangeHistoryError < StandardError; end
  class ::NonEmptyChangeHistoryError < StandardError; end
end
