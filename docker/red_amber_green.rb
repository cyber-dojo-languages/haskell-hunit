
lambda { |stdout,stderr,status|
  output = stdout + stderr
  # hunit is producing spurious hidden lines at
  # the start of stderr that end in a carriage-return
  # without a newline. Sheesh...
  cr = output.rindex("\r")
  unless cr.nil?
    output = output[cr+1..-1]
  end
  hunit_pattern = /^Cases: (\d+)  Tried: (\d+)  Errors: (\d+)  Failures: (\d+)$/
  if match = hunit_pattern.match(output)
    return :amber if match[3] != '0'
    return :red   if match[4] != '0'
    return :green
  else
    return :amber
  end
}
