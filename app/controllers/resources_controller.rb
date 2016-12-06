class ResourcesController < ApplicationController
  def index
    @resources = Resource.compute
    @resources = @resources.provider_name(params[:provider_name]) if params[:provider_name].present?
    @resources = @resources.region_area(params[:region_area]) if params[:region_area].present?
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
