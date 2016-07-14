class ProvidersController < ApplicationController
  def index
    @providers = Provider.includes(:resources)
    respond_to do |format|
      format.html
      format.json {render json: @providers, status: :ok}
    end
  end
  
  def update_all
    Provider.update_providers
    redirect_to providers_path
  end

  def names
    @names = Provider.all.map {|p| p.name}
    respond_to do |format|
      format.html
      format.json {render json: @names, status: :ok}
    end
  end
end
