class WorkloadsController < ApplicationController

  before_action :set_workload, only: [:show, :destroy, :update]


  def show
    respond_to do |format|
      format.html
      format.json {render json: @workload, status: :ok}
    end
  end

  def index
    @workloads = Workload.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @workloads, status: :ok}
    end
  end

  def create
    @workload = Workload.new
    respond_to do |format|
      if @workload.save!
        format.html
        format.json {render json: @workload, status: :created}
      else
        format.html
        format.json {render json: @workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @workload.update(workload_params)
        format.html
        format.json {render json: @workload, status: :ok}
      else
        format.html
        format.json {render json: @workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @workload.destroy
    respond_to do |format|
      format.html {redirect_to :back, notice: 'Workload was successfully destroyed.' }
      format.json {head :no_content, status: :deleted}
    end
  end

  private

    def set_workload
      @workload = Workload.find(params[:id])
    end

    def workload_params
      params.permit(:ingredient_id, :cpu_cores, :ram_mb, :requests_per_user_per_moth, :request_size_kb, :baseline_num_users)
    end

end
