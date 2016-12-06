class ResourcesController < ApplicationController
  def index
    @resources = Resource.page(params[:page])
    respond_to do |format|
      format.json {render json: @resources, status: :ok}
    end
  end

  def show
    @resource = Resource.find(params[:id])
    respond_to do |format|
      format.json {render json: @resource, status: :ok}
    end
  end
end
