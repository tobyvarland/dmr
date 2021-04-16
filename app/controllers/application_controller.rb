class ApplicationController < ActionController::Base

  # Alloy pagination.
  include Pagy::Backend

  # Include Pundit for authorization.
  include Pundit

  # Require authentication.
  before_action :authenticate_user!

end