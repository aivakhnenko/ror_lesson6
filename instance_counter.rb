module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    attr_accessor :instances_count

    def instances
      self.instances_count ||= 0
      instances_count
    end
  end

  module InstanceMethods
    protected

    def register_instance
      self.class.instances_count ||= 0
      self.class.instances_count += 1
    end
  end
end
