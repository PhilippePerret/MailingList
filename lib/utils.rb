

def require_app_folder(path)
  path = File.expand_path(File.join(APP_FOLDER,path))
  require_folder(path)
end

# Charge tous les fichiers de la boite de chemin d'accès relatif
# ou absolu +box_path+, sauf les fichiers tests.
def require_box_folder(box_path)
  box_path = File.expand_path(File.join(APP_FOLDER,box_path)) unless File.exist?(box_path)
  Dir["#{box_path}/**/*.rb"].each do |fpath|
    next if File.basename(fpath).start_with?('test')
    require fpath
  end
end

def debug(msg)
  STDOUT.write("\n#{msg}\n".orange)
end
