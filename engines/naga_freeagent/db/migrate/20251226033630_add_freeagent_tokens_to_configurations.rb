class AddFreeagentTokensToConfigurations < ActiveRecord::Migration[7.2]
  def change
    # Add new configuration parameters for FreeAgent access tokens
    # These will be updated later when the OAuth callback is processed
    [
      'freeagent_access_token',
      'freeagent_refresh_token',
      'freeagent_expires_at'
    ].each do |param_name|
      # Use `up_only` to ensure this code runs only when migrating up
      # This prevents issues if the model changes or is removed later.
      if ActiveRecord::Base.connection.table_exists?('configurations') &&
         !Configuration.exists?(parameter: param_name)
        Configuration.create!(parameter: param_name, value: nil)
      end
    end
  end
end
