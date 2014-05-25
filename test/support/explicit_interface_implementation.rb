module ExplicitInterfaceImplementation
  def implements(klass)
    @klass = klass
  end
  def implement!(method_name)
    method = @klass.instance_method(method_name)
    my_method = self.instance_method(method_name)
    unless method.arity == my_method.arity
      raise "#{@klass}'s version of #{method_name} takes #{method.arity} arguments - yours takes #{my_method.arity}"
    end
  end
end
