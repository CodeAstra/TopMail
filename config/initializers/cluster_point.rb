ClusterPoint::Configuration.class_eval do
	def load_config
    @file = (Rails.root ? Rails.root.to_s : ".") + "/config/cluster_point.yml"
    @env = Rails.env
    if !File.exists?(@file)
      puts "Here is an error"
    end
    begin
      data = YAML.load_file(@file)
    rescue ArgumentError, Psych::SyntaxError => error
      raise Fixture::FormatError, "a YAML error occurred parsing #{@file}. Please note that YAML must be consistently indented using spaces. Tabs are not allowed. Please have a look at http://www.yaml.org/faq.html\nThe exact error was:\n  #{error.class}: #{error}", error.backtrace
    end
    if !data.has_key?(@env)
      puts "Here is an error"
    end
    @config = data[@env]

    self.class.base_uri get_base_uri(@config)
    if @config["debug_output"]
      self.class.debug_output $stdout
    end
  end
end