class NormaliseSpecialistDocumentDates < Mongoid::Migration

  @editions = Class.new do
    include Mongoid::Document
    store_in :specialist_document_editions
    field :extra_fields, type: Hash, default: {}

    def opened_date
      read_attribute(:opened_date)
    end

    def closed_date
      read_attribute(:closed_date)
    end

    def fix_dates!
      new_opened_date = new_date_for(opened_date)
      new_closed_date = new_date_for(closed_date)

      fix_date!("opened_date", new_opened_date)
      fix_date!("closed_date", new_closed_date) unless new_closed_date.nil?
    end

  private
    def fix_date!(field, new_date)
      stop_mongoid_casting_strings_to_dates(field)

      extra_fields[field] = new_date
      update_attribute(field, new_date)
      update_attribute(:extra_fields, extra_fields)
    end

    def new_date_for(date)
      case date
      when Time then date_from_time(date)
      when String then date_from_string(date)
      when nil then nil
      else raise "Unexpected date type: #{date.class.name}"
      end
    end

    # Really, mongoid? Really?
    # So, if you update an attribute that is currently a Time, to something
    # which *can* be cast into a time (but is a string), mongo *will* then cast
    # it back to a Time datatype.
    #
    # Bad mongoid. No donut.
    #
    # Force it to be something non-datelike first to stop mongoid from casting
    # the new 'stringy' date to a Time.
    def stop_mongoid_casting_strings_to_dates(field)
      extra_fields[field] = "PORK"
      update_attribute(field, "PORK")
      update_attribute(:extra_fields, extra_fields)
    end

    def date_from_time(time_object)
      time_object.strftime("%Y-%m-%d")
    end

    def date_from_string(string_object)
      if string_object =~ /^\d{4}-\d{2}-\d{2}$/
        string_object
      else
        Time.parse(string_object).strftime("%Y-%m-%d")
      end
    end
  end

  def self.up
    @editions.where(document_type: "cma_case").each do |edition|
      edition.fix_dates!
    end
  end

  def self.down
    # I'm not going to let you put the data back to this terrible, terrible
    # state.
    raise IrreversibleMigration
  end
end
