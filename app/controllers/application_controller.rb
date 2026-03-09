class ApplicationController < ActionController::Base
  include Authentication

  private

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || user_path(current_user)
  end
end
