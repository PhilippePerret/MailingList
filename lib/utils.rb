

def require_folder(path)
  Dir["#{path}/**/*.rb"].each do |m|
    next if File.basename(m).match?(/^test/)
    require m
  end
end

def debug(msg)
  STDOUT.write("\n#{msg}\n".orange)
end
