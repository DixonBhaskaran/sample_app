class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      # Activate the user
      log_in user
      flash[:success] = 'Account activated!'
      redirect_to user
    else
      # Handle in valid link
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
