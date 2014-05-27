#Fog.mock!
#Fog.credentials_path = Rails.root.join('config/fog_credentials.yml')

#Fog.credential = {
#    :provider => 'AWS',
#    :aws_access_key_id => $config['amazon']['access_key_id'],
#    :aws_secret_access_key => $config['amazon']['secret_access_key']
#}

#connection = Fog::Storage.new(:provider => 'AWS')
#connection.directories.create(:key => $config['amazon']['instruction_bucket'])

#unless Kernel.const_defined?("S3_CONFIG")
#  S3_CONFIG = YAML.load_file("#{Rails.root}/config/fog_credentials.yml")[Rails.env].try(:symbolize_keys)
#end

Fog.mock!

connection = ::Fog::Storage.new(
    :aws_access_key_id => AmazonConfig.config.access_key,
    :aws_secret_access_key => AmazonConfig.config.secret,
    :provider => 'AWS'
)

connection.directories.create(:key => AmazonConfig.config.instruction_bucket)