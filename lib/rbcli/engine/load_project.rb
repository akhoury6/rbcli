module Rbcli
	def self.load_project
		project_root = File.expand_path "#{File.dirname(caller[0].split(':')[0])}/../"

		# We require all ruby files as-is
		%w(config hooks application application/commands).each do |dir|
			dirpath = "#{project_root}/#{dir}"
			Dir.glob "#{dirpath}/*.rb" do |file|
				require file
			end if Dir.exists? dirpath
		end

		# We automatically pull in default user configs
		configspath = "#{project_root}/default_user_configs"
		Dir.glob "#{configspath}/*.{yml,yaml}" do |file|
			Rbcli::Configurate.me {config_defaults file}
		end
	end
end