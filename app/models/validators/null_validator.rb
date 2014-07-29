class NullValidator < SimpleDelegator
  def valid?
    true
  end

  def errors
    {}
  end
end
