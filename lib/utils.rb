

def require_folder(path)
  path = File.expand_path(File.join(APP_FOLDER,path)) unless File.exist?(path)
  Dir["#{path}/**/*.rb"].each do |m|
    next if File.basename(m).match?(/^test/)
    require m
  end
end

def debug(msg)
  STDOUT.write("\n#{msg}\n".orange)
end
