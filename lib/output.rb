module Output
  module_function

  def write(str)
    print "\033c " + str
  end

  def write_new_line(str)
    puts str
  end
end
