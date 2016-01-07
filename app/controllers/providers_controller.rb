class ProvidersController < ApplicationController
  def index
    @providers = Provider.includes(:resources)
  end
  
  def update_all
    Provider.update_providers
    redirect_to providers_path
  end
end
