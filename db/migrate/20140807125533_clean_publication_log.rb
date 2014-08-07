class CleanPublicationLog < Mongoid::Migration
  @publication_logs = Class.new do
    include Mongoid::Document
    store_in :publication_logs
  end

  def self.up
    @publication_logs.destroy_all
  end

  def self.down
    # Nothing to do here \o/
  end
end
