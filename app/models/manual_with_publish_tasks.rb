require "delegate"

class ManualWithPublishTasks < SimpleDelegator

  def initialize(manual, attrs)
    super(manual)
    @publish_tasks = attrs.fetch(:publish_tasks)
  end

  def publish_tasks
    @publish_tasks.to_enum
  end

end
