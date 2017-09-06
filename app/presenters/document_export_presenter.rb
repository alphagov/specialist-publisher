module DocumentExportPresenter
  NotExportableError = Class.new(StandardError)
  def self.for(document_klass)
    raise NotExportableError, "#{document_klass.document_type} is not exportable" unless document_klass.exportable?

    begin
      "#{document_klass.name}ExportPresenter".constantize
    rescue NameError
      raise NotExportableError, "#{document_klass.document_type} is exportable, but we don't know what its exporter class is"
    end
  end
end
