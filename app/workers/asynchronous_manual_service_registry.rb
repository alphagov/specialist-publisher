class AsynchronousManualServiceRegistry

  def publish(id, version_number)
    PublishManualWorker.perform_async(id, version_number)
  end
end
