# app/controllers/freeagent_controller.rb
class FreeagentController < ApplicationController
  def auth
    # This URL should match one configured in your FreeAgent developer app.
    # For development, you might use http://localhost:3000/freeagent/callback
    redirect_uri = freeagent_callback_url

    # Generate the authorization URL and redirect the user
    authorize_url = NagaFreeagent::Service.authorize_url(redirect_uri)
    redirect_to authorize_url, allow_other_host: true
  end

  def callback
    code = params[:code]
    if code.present?
      begin
        redirect_uri = freeagent_callback_url
        access_token_obj = NagaFreeagent::Service.get_access_token(code, redirect_uri)

        FreeagentAuth.set_tokens(
          access_token_obj.token,
          access_token_obj.refresh_token,
          Time.at(access_token_obj.expires_at)
        )

        flash[:notice] = "Successfully connected to FreeAgent!"
        redirect_to root_path
      rescue OAuth2::Error => e
        Rails.logger.error "FreeAgent OAuth callback error: #{e.message}"
        flash[:error] = "FreeAgent connection failed: #{e.description || e.message}. Please try again."
        redirect_to root_path
      end
    else
      flash[:error] = "FreeAgent connection failed: #{params[:error_description] || 'No authorization code received.'}"
      redirect_to root_path
    end
  end
end
