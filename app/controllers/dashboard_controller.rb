class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @trader = current_user.email
  end

  
end