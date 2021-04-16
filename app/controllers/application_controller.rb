class ApplicationController < ActionController::Base

  # Alloy pagination.
  include Pagy::Backend

  # Require authentication.
  before_action :authenticate_user!

end