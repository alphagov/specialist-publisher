require "fast_spec_helper"
require "document_repository_observer_mapper"

RSpec.describe DocumentRepositoryObserverMapper do
  subject(:mapper) { DocumentRepositoryObserverMapper.new(mapping) }

  let(:mapping) {
    {
      "foo" => foo,
      "bar" => bar,
    }
  }

  let(:foo) {
    double(:tuple,
           repository: double(:repository),
           observer: double(:observer)
    )
  }

  let(:bar) {
    double(:tuple,
           repository: double(:repository),
           observer: double(:observer)
    )
  }

  it "returns all observers for a nil document type" do
    listeners = mapper.repository_listeners(nil)
    expect(listeners.size).to eq(2)
    expect(listeners).to eq([foo, bar])
  end

  it "returns the relevant observer if a document type is provided" do
    listeners = mapper.repository_listeners("foo")
    expect(listeners.size).to eq(1)
    expect(listeners.first).to eq(foo)
  end

  it "raises if an unknown document type is requested" do
    expect { mapper.repository_listeners("baz") }.to raise_error
  end
end
