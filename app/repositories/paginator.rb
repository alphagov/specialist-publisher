class RepositoryPaginator < SimpleDelegator
  def initialize(repo)
    @repo = repo
    @pipeline = []
    super(@repo)
  end

  def [](offset, limit)
    apply_pipeline(repo.all(limit, offset))
  end

  def map(*args, &block)
    pipeline.push([:map, block])

    self
  end

  def count
    repo.count
  end

private

  attr_reader :repo, :pipeline

  def apply_pipeline(results)
    pipeline.reduce(results) { |collection, (op, func)|
      collection.public_send(op, &func)
    }
  end
end
