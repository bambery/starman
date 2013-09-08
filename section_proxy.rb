require 'json'

module Starman
  class SectionProxy

    def initialize(section_name)
      @section_name = section_name
      @files = get_section_content
      @proxy = {}
    end

    def self.proxies_dir
      File.join(Content.raw_content_dir, 'proxies')
    end

    def get_section_content
      Content.get_content(File.join(Content.raw_content_dir, @section_name, '/*'))
    end

    ##
    # This will create a proxy file for each folder under the content directory 
    # in order to represent each section in the manifest. The proxy file's 
    # thumbprint will depend on the contents of the folder, and will update if
    # the directory's contents change. This file name will be used as the 
    # memcached key. This file should be executed after configuring 
    # CloudCrooner and before compiling assets. All proxies are recreated
    # every time assets are compiled, but since this is done before rolling
    # out, who cares?
    #
    # Be nice if this worked: https://github.com/sstephenson/sprockets/issues/452
    #  
    def self.create_section_proxies
      empty_section_proxies
      sections = Dir.glob(Content.raw_content_dir + "/*/")
      p sections
      sections.each do |section| 
        proxy = SectionProxy.new(File.basename(section))
        proxy.write_proxy_for_section
      end
    end

    def write_proxy_for_section
      return if @files.empty?
      @files.each do |section_file|
        @proxy[File.basename(section_file)] = Digest::MD5.file(section_file)
      end
       # proxy file is a json of the filenames and their digests
      File.open(File.join(SectionProxy.proxies_dir, "#{@section_name}-proxy.json"), "w") do |f|
        f.write(JSON.generate(@proxy))
      end
    end

    ##
    # delete old proxies folder if it exists in case sections have been removed
    #
    def self.empty_section_proxies
      FileUtils.rm_rf(proxies_dir, secure: true) if Dir.exist?(proxies_dir)
      FileUtils.mkdir_p(proxies_dir) 
    end

  end
end
