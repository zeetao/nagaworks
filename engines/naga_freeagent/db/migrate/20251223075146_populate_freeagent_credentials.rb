class PopulateFreeagentCredentials < ActiveRecord::Migration[7.2]
  def up
    oauth_id = Rails.application.credentials.dig(:freeagent, :oauth_id)
    oauth_secret = Rails.application.credentials.dig(:freeagent, :oauth_secret)

    if oauth_id.present? && oauth_secret.present?
      execute("INSERT INTO configurations (parameter, value, created_at, updated_at) VALUES ('freeagent_oauth_id', '#{oauth_id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)")
      execute("INSERT INTO configurations (parameter, value, created_at, updated_at) VALUES ('freeagent_oauth_secret', '#{oauth_secret}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)")
    else
      say "FreeAgent credentials not found in credentials.yml.enc, skipping seeding."
    end
  end

  def down
    execute("DELETE FROM configurations WHERE parameter IN ('freeagent_oauth_id', 'freeagent_oauth_secret')")
  end
end
