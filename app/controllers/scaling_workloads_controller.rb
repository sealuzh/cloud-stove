class ScalingWorkloadsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_scaling_workload, only: [:show, :destroy, :update]


  def show
    respond_to do |format|
      format.html
      format.json {render json: @scaling_workload, status: :ok}
    end
  end

  def index
    @scaling_workloads = current_user.scaling_workloads.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @scaling_workloads, status: :ok}
    end
  end

  def new
   @scaling_workload = if params[:copy]
     ScalingWorkload.find(params[:copy]).deep_dup
   else
     ScalingWorkload.new
   end
  end

  def create
    @scaling_workload = ScalingWorkload.new
    @scaling_workload.update_attributes(scaling_workload_params)
    @scaling_workload.user = current_user
    respond_to do |format|
      if @scaling_workload.save!
        format.html {redirect_to @scaling_workload, notice: 'Scaling workload was successfully created!'}
        format.json {render json: @scaling_workload, status: :created}
      else
        format.html
        format.json {render json: @scaling_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @scaling_workload.update(scaling_workload_params)
        format.html
        format.json {render json: @scaling_workload, status: :ok}
      else
        format.html
        format.json {render json: @scaling_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @scaling_workload.destroy
    respond_to do |format|
      format.html {redirect_to :back, notice: 'Scaling workload was successfully destroyed.' }
      format.json {head :no_content, status: :deleted}
    end
  end

  private

    def set_scaling_workload
      @scaling_workload = current_user.scaling_workloads.find(params[:id])
    end

    def scaling_workload_params
      params.require(:scaling_workload).permit(:ingredient_id, :scale_ingredient)
    end

end
