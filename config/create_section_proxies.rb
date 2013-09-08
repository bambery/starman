# This will create a proxy file for each folder under the content directory in 
# order to represent each section in the manifest. 
# The proxy file's thumbprint will depend on the contents of the folder, 
# and will update if the directory's contents change. This file name will be 
# used as the memcached key. This file should be executed after configuring 
# CloudCrooner and before compiling assets.

compiled_folder = CloudCrooner.manifest.dir
proxies_folder = File.join(compiled_folder, 'proxies')
# delete old proxies folder if it exists in case sections have been removed
FileUtils.rm_rf(proxies_folder, secure: true) if Dir.exist?(proxies_folder)
# grab each section
sections = Dir.glob(compiled_folder + "/*/").map { |i| File.basename(i) }
FileUtils.mkdir_p(proxies_folder) 
# for each file in the section, generate an MD5 digest of the file
sections.each do |section|
  section_proxy = {}
  p "writing #{section} proxy"
  section_files = Dir.glob(File.join(compiled_folder, 'content', section, '/*'))
  section_files.select { |file| !File.directory?(file) }
  section_files.each do |s_file|
    section_proxy[File.basename(s_file)] = Digest::MD5.file(s_file)
  end
  # proxy file is a json of the filenames and their digests
  File.open(File.join(proxies_folder, "#{section}-proxy.json", "w") do |f|
    f.write(JSON.generate(section_proxy))
  end
end
