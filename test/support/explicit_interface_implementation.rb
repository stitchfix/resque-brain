module ExplicitInterfaceImplementation
  def implements(klass)
    @klass = klass
  end
  def implement!(method_name)
    unless @klass.instance_methods.include?(method_name)
      raise "#{@klass} does not implement #{method_name}"
    end
  end
end
