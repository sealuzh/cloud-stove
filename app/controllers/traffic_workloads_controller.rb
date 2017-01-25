class TrafficWorkloadsController < ApplicationController
  before_action :set_traffic_workload, only: [:show, :destroy, :update]

  def show
    respond_to do |format|
      format.html
      format.json {render json: @traffic_workload, status: :ok}
    end
  end

  def index
    @traffic_workloads = current_user.traffic_workloads.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @traffic_workloads, status: :ok}
    end
  end

  def new
   @traffic_workload = if params[:copy]
     TrafficWorkload.find(params[:copy]).deep_dup
   else
     TrafficWorkload.new
   end
  end

  def create
    @traffic_workload = TrafficWorkload.new
    @traffic_workload.update_attributes(traffic_workload_params)
    @traffic_workload.user = current_user
    respond_to do |format|
      if @traffic_workload.save!
        format.html {redirect_to @traffic_workload, notice: 'TrafficWorkload was successfully created!'}
        format.json {render json: @traffic_workload, status: :created}
      else
        format.html
        format.json {render json: @traffic_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @traffic_workload.update(traffic_workload_params)
        format.html
        format.json {render json: @traffic_workload, status: :ok}
      else
        format.html
        format.json {render json: @traffic_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @traffic_workload.destroy
    respond_to do |format|
      format.html {redirect_to :back, notice: 'TrafficWorkload was successfully destroyed.' }
      format.json {head :no_content, status: :deleted}
    end
  end

  private

    def set_traffic_workload
      @traffic_workload = current_user.traffic_workloads.find(params[:id])
    end

    def traffic_workload_params
      params.require(:traffic_workload).permit(:ingredient_id, :requests_per_visit, :request_size_kb, :visits_per_month)
    end
end
