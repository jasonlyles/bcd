# frozen_string_literal: true

class Admin::EtsyController < AdminController
  # This action is to retrieve the code sent back to us from Etsy from their OAuth
  # flow, and send it, along with the code verifier saved to session earlier, back
  # to Etsy to get access tokens. We then store those tokens for later API usage.
  def callback
    tokens = Etsy::Api::AccessToken.get(params[:code], session[:etsy_code_verifier])
    Etsy::Api::AccessToken.store(tokens[:access_token], tokens[:refresh_token], tokens[:expires_at])

    redirect_to admin_products_path
  end

  def redirect_to_etsy_oauth
    code_challenge = create_pkce_challenge_codes

    state = SecureRandom.hex(5)
    redirect_uri = "#{Rails.application.config.web_host}/etsy/callback"
    # scopes must be separated by a space character
    scope = 'listings_r%20transactions_r%20listings_w%20listings_d'
    client_id = Rails.application.credentials.etsy.api_key

    etsy_url = <<~URL.squish.gsub(/\s/, '')
      https://www.etsy.com/oauth/connect?
      response_type=code&
      redirect_uri=#{redirect_uri}&
      scope=#{scope}&
      client_id=#{client_id}&
      state=#{state}&
      code_challenge=#{code_challenge}&
      code_challenge_method=S256
    URL

    redirect_to etsy_url, allow_other_host: true
  end

  private

  # Set up the PKCE challenge strings, save the code_verifier to session, and return
  # the code_challenge, as it's needed for the next step.
  def create_pkce_challenge_codes
    pkce_challenge = PkceChallenge.challenge
    # Store code_verifier for later
    session[:etsy_code_verifier] = pkce_challenge.code_verifier

    pkce_challenge.code_challenge
  end
end
