class ApplicationController < ActionController::Base

  # Alloy pagination.
  include Pagy::Backend

  # Include Pundit for authorization.
  include Pundit

  # Require authentication.
  before_action :authenticate_user!

  # Error handling.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # rescue_from ActionController::RedirectBackError, with: :redirect_to_root

  private

    # Handles Pundit authorization error.
    def user_not_authorized
      flash[:error] = "You're not authorized for that function. Please try again or contact IT."
      redirect_back fallback_location: root_path
    end

end