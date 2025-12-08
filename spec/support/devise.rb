RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Ensure Devise mappings are loaded for controller specs so sign_in works
  config.before(:suite) do
    Rails.application.reload_routes!
  end

  # Ensure Devise knows which mapping to use in controller specs
  config.before(:each, type: :controller) do
    mapping = Devise.mappings[:user] || Devise.mappings.values.first
    raise "Devise user mapping is missing" unless mapping

    @request.env['devise.mapping'] = mapping
  end
end
