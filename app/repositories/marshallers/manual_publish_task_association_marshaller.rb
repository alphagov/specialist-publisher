class ManualPublishTaskAssociationMarshaller
  def initialize(dependencies = {})
    @decorator = dependencies.fetch(:decorator)
    @collection = dependencies.fetch(:collection)
  end

  def load(manual, _record)
    tasks = collection.for_manual(manual)

    decorator.call(manual, publish_tasks: tasks)
  end

  def dump(_manual, _record)
    # PublishTasks are read only
    nil
  end

private
  attr_reader :collection, :decorator
end
