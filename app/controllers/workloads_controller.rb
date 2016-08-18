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

  def new
   @levels = levels
   @workload = if params[:copy]
     Workload.find(params[:copy]).deep_dup
   else
     Workload.new
   end
  end

  def create
    @workload = Workload.new
    @workload.update_attributes(workload_params)
    respond_to do |format|
      if @workload.save!
        format.html {redirect_to @workload, notice: 'Workload was successfully created!'}
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

    def levels
      {'low'=>0, 'medium-low'=>1, 'medium'=>2, 'medium-high'=>3, 'high'=>4}
    end


    def set_workload
      @workload = Workload.find(params[:id])
    end

    def workload_params
      params.require(:workload).permit(:ingredient_id, :cpu_level, :ram_level, :requests_per_visit, :request_size_kb, :visits_per_month)
    end

end
