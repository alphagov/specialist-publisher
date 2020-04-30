until ARGF.eof?
  entry = ARGF.readline.rstrip
  puts %({"label": "#{entry}", "value": "#{entry.parameterize}"},)
end
