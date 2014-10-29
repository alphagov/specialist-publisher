require "builders/specialist_document_builder"

class DependencyContainer
  def initialize(&block)
    @definitions = {}
    instance_eval(&block) if block_given?
  end

  def define_factory(name, &block)
    @definitions[name] = FactoryDependency.new(self, block)
  end

  def define_singleton(name, &block)
    @definitions[name] = SingletonDependency.new(self, block)
  end

  def define_instance(name, instance = nil, &block)
    instance = block.call if block_given?
    @definitions[name] = InstanceDependency.new(self, instance)
  end

  def get(name)
    definition(name).get
  end

  def dependency_defined?(name)
    @definitions.has_key?(name)
  end

  def definition(name)
    @definitions[name] || raise("Missing dependency #{name}")
  end

  def inject_into(klass, visibility: :private)
    @definitions.each do |name, dependency|
      unless klass.method_defined?(name)
        klass.send(:define_method, name) { dependency.get }
        klass.send(visibility, name)
      end
    end
  end

protected

  def dependencies_for(klass)
    if klass.respond_to?(:members)
      klass.members.map do |member|
        get(member)
      end
    else
      initializer_parameters = begin
        klass.instance_method(:initialize).parameters
      rescue NameError
        []
      end
      initializer_parameters.map do |(arg_type, arg_name)|
        case arg_type
        when :req
          get(arg_name)
        when :opt
          get(arg_name) if dependency_defined?(arg_name)
        when :rest
        when :key
        when :keyrest
        end
      end
    end
  end

  def build_with_dependencies(klass)
    klass.new(*dependencies_for(klass))
  end

  class FactoryDependency < Struct.new(:container, :callable)
    def get
      container.instance_eval(&callable)
    end
  end

  class SingletonDependency < FactoryDependency
    def get
      @instance ||= super
    end
  end

  class InstanceDependency < Struct.new(:container, :instance)
    def get
      self.instance
    end
  end
end
