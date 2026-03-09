class SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  def create
    name = params.dig(:user, :name).to_s.strip
    password = params.dig(:user, :password)

    user = User.find_by(name: name)

    if user&.authenticate(password)
      start_new_session_for(user)      # cookie側
      session[:user_id] = user.id      # spec互換用

      redirect_to user_path(user), notice: "Signed in successfully.", status: :see_other
    else
      redirect_to new_session_path, alert: "Invalid name or password.", status: :see_other
    end
  end

  def destroy
    terminate_session
    session.delete(:user_id)
    redirect_to root_path, notice: "Signed out successfully.", status: :see_other
  end
end
