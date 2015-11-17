class CloudApplicationsController < ApplicationController
  def index
    @applications = CloudApplication.all
  end
end
