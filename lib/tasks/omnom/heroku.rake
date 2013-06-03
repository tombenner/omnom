desc 'Start Omnom\'s background processing'
namespace :omnom do
  namespace :heroku do
    desc "Prints the Heroku config command (heroku config:add) that sets all environment variables listed in settings.yml"
    task :config, [:file_name] do |t, args|
      file_name = args[:file_name] || 'omnom'

      heroku_settings = flatten_hash_keys(YAML.load_file(Rails.root.join('config', "#{file_name}.yml")))
      local_settings = flatten_hash_keys(YAML.load_file(Rails.root.join('config', "#{file_name}.local.yml")))
      env_vars = {}

      heroku_settings.each do |heroku_key, heroku_value|
        if heroku_value =~ /^<%= ENV\['([^\]]+)'\] %>$/
          config_name = $1
          config_value = local_settings[heroku_key]
          env_vars[config_name] = config_value
        end
      end
      command_arguments = env_vars.collect do |key, value|
        if value.nil?
          puts "#{key} has a nil value and was bypassed"
          next
        end
        value = Shellwords.escape(value.to_s)
        "#{key}=#{value}"
      end
      command_arguments_string = command_arguments.compact.join(' ')
      puts "\nRun the following command to update your Heroku config values:\n\n"
      puts "heroku config:add #{command_arguments_string}\n\n"
    end

    private

    def flatten_hash_keys(input, output={}, options={})
      input.each do |key, value|
        key = options[:prefix].nil? ? key.to_s : "#{options[:prefix]}#{options[:delimiter] || '_'}#{key}"
        if value.is_a?(Hash)
          flatten_hash_keys(value, output, :prefix => key, :delimiter => '_')
        elsif value.is_a?(Array)
          flatten_array_keys(key, value, output, :prefix => key, :delimiter => '_')
        else
          output[key] = value
        end
      end
      output
    end

    def flatten_array_keys(key, array, output={}, options={})
      array.each_with_index do |hash, index|
        flatten_hash_keys(hash, output, :prefix => "#{key}__#{index}", :delimiter => '_')
      end
    end
  end
end