module Rbcli
	def self.load_project
		project_root = File.expand_path("#{File.dirname(caller[0].split(':')[0])}/../")

		# Add lib to the load path for the user's convenience
		lib = "#{project_root}/lib"
		$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

		# We require all ruby files as-is
		%w(config hooks application application/commands).each do |dir|
			dirpath = "#{project_root}/#{dir}"
			Dir.glob "#{dirpath}/*.rb" do |file|
				require file
			end if Dir.exists? dirpath
		end

		# We automatically pull in default user configs
		configspath = "#{project_root}/userconf"
		Dir.glob "#{configspath}/*.{yml,yaml,json}" do |file|
			Rbcli::Configurate.me {config_defaults file}
		end

	end
end