# frozen_string_literal: true

class IncorrectPinterestState < StandardError; end

class Admin::PinterestController < AdminController
  # This action is to retrieve the code sent back to us from Pinterest from their OAuth
  # flow, and send it, after verifying the state saved to session earlier, back
  # to Pinterest to get access tokens. We then store those tokens for later API usage.
  def callback
    raise IncorrectPinterestState if session[:pinterest_state] != params[:state]

    tokens = Pinterest::Api::AccessToken.get(params[:code])
    Pinterest::Api::AccessToken.store(tokens[:access_token], tokens[:refresh_token], tokens[:expires_at])

    redirect_to admin_products_path
  end

  def redirect_to_pinterest_oauth
    state = SecureRandom.hex(5)
    redirect_uri = "#{Rails.application.config.web_host}/pinterest/callback"
    # scopes must be separated by a comma
    scope = 'boards:read,boards:write,pins:read,pins:write'

    client_id = Rails.application.credentials.pinterest.app_id

    pinterest_url = <<~URL.squish.gsub(/\s/, '')
      https://www.pinterest.com/oauth?
      response_type=code&
      redirect_uri=#{redirect_uri}&
      scope=#{scope}&
      client_id=#{client_id}&
      state=#{state}
    URL
    session[:pinterest_state] = state

    redirect_to pinterest_url, allow_other_host: true
  end
end
