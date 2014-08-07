require "state_machine"

class ManualPublishTask
  include Mongoid::Document
  include Mongoid::Timestamps

  field :manual_id, type: String
  field :version_number, type: Integer
  field :state, type: String
  field :error, type: String

  state_machine initial: :queued do
    event :start! do
      transition queued: :processing
    end

    event :finish! do
      transition processing: :finished
    end

    event :abort! do
      transition processing: :aborted
    end
  end

end
