class CpuWorkloadsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_cpu_workload, only: [:show, :destroy, :update]


  def show
    respond_to do |format|
      format.html
      format.json {render json: @cpu_workload, status: :ok}
    end
  end

  def index
    @cpu_workloads = current_user.cpu_workloads.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @cpu_workloads, status: :ok}
    end
  end

  def new
   @cpu_workload = if params[:copy]
     CpuWorkload.find(params[:copy]).deep_dup
   else
     CpuWorkload.new
   end
  end

  def create
    @cpu_workload = CpuWorkload.new
    @cpu_workload.update_attributes(cpu_workload_params)
    @cpu_workload.user = current_user
    respond_to do |format|
      if @cpu_workload.save!
        format.html {redirect_to @cpu_workload, notice: 'CPU Workload was successfully created!'}
        format.json {render json: @cpu_workload, status: :created}
      else
        format.html
        format.json {render json: @cpu_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @cpu_workload.update(cpu_workload_params)
        format.html
        format.json {render json: @cpu_workload, status: :ok}
      else
        format.html
        format.json {render json: @cpu_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @cpu_workload.destroy
    respond_to do |format|
      format.html {redirect_to :back, notice: 'CPU Workload was successfully destroyed.' }
      format.json {head :no_content, status: :deleted}
    end
  end

  private

    def set_cpu_workload
      @cpu_workload = current_user.cpu_workloads.find(params[:id])
    end

    def cpu_workload_params
      params.require(:cpu_workload).permit(:ingredient_id, :cspu_user_capacity, :parallelism)
    end

end
