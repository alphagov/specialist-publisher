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

protected

  attr_accessor :items

  class Item
    attr_accessor :public_timestamp, :change_note

    def initialize(public_timestamp:, change_note:)
      self.public_timestamp = public_timestamp
      self.change_note = change_note
    end
  end

  class ::EmptyChangeHistoryError < StandardError; end
  class ::NonEmptyChangeHistoryError < StandardError; end
end
