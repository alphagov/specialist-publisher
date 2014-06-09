require "spec_helper"
require "dependency_container"

describe DependencyContainer do

  class ExampleClass; end

  it "builds object instances from a factory defined by a passed-in block" do
    container = DependencyContainer.new
    container.define_factory(:example) { ExampleClass.new }

    expect(container.get(:example)).to be_a ExampleClass
    expect(container.get(:example)).to_not equal container.get(:example)
  end

  it "fetches registered object instances" do
    my_instance = ExampleClass.new
    container = DependencyContainer.new
    container.define_instance(:example, my_instance)

    expect(container.get(:example)).to equal my_instance
  end

  it "fetches registered object instances defined by block" do
    my_instance = ExampleClass.new
    container = DependencyContainer.new
    container.define_instance(:example) { my_instance }

    expect(container.get(:example)).to equal my_instance
  end

  it "builds a single instance of singleton factories" do
    container = DependencyContainer.new
    container.define_singleton(:example) { ExampleClass.new }

    expect(container.get(:example)).to be_a ExampleClass
    expect(container.get(:example)).to equal container.get(:example)
  end

  it "allows initial wiring to be defined in block passed to constructor" do
    container = DependencyContainer.new do
      define_singleton(:example) { ExampleClass.new }
    end

    expect(container.get(:example)).to be_a ExampleClass
  end

  describe "#inject_into" do
    let(:container) {
      DependencyContainer.new.tap { |c|
        c.define_singleton(:example) { ExampleClass.new }
      }
    }

    let(:target_class) { Class.new }

    context "without a visibity option" do
      it "injects private helper methods for all defined dependencies" do
        container.inject_into(target_class)

        expect(target_class.private_instance_methods).to include(:example)
        expect(target_class.new.send(:example)).to be_a ExampleClass
      end
    end

    context "with visibility option set to public" do
      it "injects private helper methods for all defined dependencies" do
        container.inject_into(target_class, visibility: :public)

        expect(target_class.public_instance_methods).to include(:example)
        expect(target_class.new.send(:example)).to be_a ExampleClass
      end
    end

    context "with visibility option set to protected" do
      it "injects protected helper methods for all defined dependencies" do
        container.inject_into(target_class, visibility: :protected)

        expect(target_class.protected_instance_methods).to include(:example)
        expect(target_class.new.send(:example)).to be_a ExampleClass
      end
    end
  end

  context "a class with a constructor dependency" do
    before(:all) do
      class PublishingService
        attr_reader :logger
        def initialize(logger)
          @logger = logger
        end
      end
      MyLogger = Class.new
    end

    before(:each) do
      @container = DependencyContainer.new
      @container.define_factory(:publishing_service) do
        PublishingService.new(get(:logger))
      end
      @container.define_factory(:logger) do
        MyLogger.new
      end
    end

    it "gives the factory access to the container to allow dependencies to be fetched" do
      publishing_service_instance = @container.get(:publishing_service)
      expect(publishing_service_instance).to be_a PublishingService
      expect(publishing_service_instance.logger).to be_a MyLogger
    end

    it "can build an object with dependencies based on the initializer's arguments" do
      @container.define_factory(:another_publishing_service) do
        build_with_dependencies(PublishingService)
      end
      publishing_service_instance = @container.get(:another_publishing_service)

      expect(publishing_service_instance).to be_a PublishingService
      expect(publishing_service_instance.logger).to be_a MyLogger
    end

    it "can build a Struct with dependencies based on the struct members" do
      struct = Struct.new(:logger)

      @container.define_factory(:my_struct) do
        build_with_dependencies(struct)
      end

      instance = @container.get(:my_struct)
      expect(instance).to be_a struct
      expect(instance.logger).to be_a MyLogger
    end

    it "will set optional dependencies if defined" do
      my_class = Class.new do
        def initialize(logger = nil, not_defined = nil)
        end
      end

      @container.define_factory(:test)
    end
  end
end
