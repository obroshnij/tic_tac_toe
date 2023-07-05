module Output
  module_function

  def write(str)
    print "\033c " + str
  end
end
