require 'net/http'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action do
    @application_name = ENV.fetch('CANONICAL_NAME', 'Disaster API')
  end

  def admin?
    user_signed_in? && current_user.admin?
  end

  def authenticate_admin!
    if !admin?
      redirect_to request.referrer || root_path, notice: "Admins Only! :|"
    end
  end

  def send_slack_notification msg
    uri = URI('https://slack.com/api/chat.postMessage')
    params = { :token => Rails.application.secrets.slack_token, :channel => Rails.application.secrets.slack_channel, :text => msg, :pretty => 1 }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      puts "Slack response: #{res.body}"
    else
      puts "Slack request failed: #{res}"
    end
  end
end
