class ProvidersController < ApplicationController
  def index
    @providers = Provider.includes(:resources)
  end
end
