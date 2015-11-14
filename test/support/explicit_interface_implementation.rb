module ExplicitInterfaceImplementation
  def implements(klass)
    @klass = klass
  end

  # require that the method exist on the faked-out class
  def implement(method_name)
    return if ruby1?
    method = @klass.instance_method(method_name)
  end

  # require that the method exist AND the arity match on the faked-out class
  def implement!(method_name)
    return if ruby1?
    method = @klass.instance_method(method_name)
    my_method = self.instance_method(method_name)
    unless method.arity == my_method.arity
      additional_info = if method.arity == -1
                          MESSAGE_ABOUT_NEGATIVE_ARITY
                        else
                          ""
                        end
      raise "#{@klass}'s version of #{method_name} takes #{method.arity} arguments - yours takes #{my_method.arity}#{additional_info}"
    end
  end

  def implement_ghost!(method_name)
  end

  MESSAGE_ABOUT_NEGATIVE_ARITY = ". NOTE: For Ruby methods that take a variable number of arguments, a negative value for arity means that for n required arguments, the arity is -n-1.  Not to be confusing, but methods written in C return -1, if the call takes a variable number of arguments."

private

  def ruby_1?
    major,_minor,_rest = RUBY_VERSION.split(/\./,3)
    major.to_i == 1
  end
end
