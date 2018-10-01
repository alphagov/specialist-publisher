until ARGF.eof? do
  entry = ARGF.readline.rstrip
  puts %|{"label": "#{entry}", "value": "#{entry.parameterize}"},|
end
