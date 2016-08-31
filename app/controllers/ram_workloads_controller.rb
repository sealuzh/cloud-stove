class RamWorkloadsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_ram_workload, only: [:show, :destroy, :update]


  def show
    respond_to do |format|
      format.html
      format.json {render json: @ram_workload, status: :ok}
    end
  end

  def index
    @ram_workloads = current_user.ram_workloads.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @ram_workloads, status: :ok}
    end
  end

  def new
   @ram_workload = if params[:copy]
     RamWorkload.find(params[:copy]).deep_dup
   else
     RamWorkload.new
   end
  end

  def create
    @ram_workload = RamWorkload.new
    @ram_workload.update_attributes(ram_workload_params)
    @ram_workload.user = current_user
    respond_to do |format|
      if @ram_workload.save!
        format.html {redirect_to @ram_workload, notice: 'RAM Workload was successfully created!'}
        format.json {render json: @ram_workload, status: :created}
      else
        format.html
        format.json {render json: @ram_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @ram_workload.update(ram_workload_params)
        format.html
        format.json {render json: @ram_workload, status: :ok}
      else
        format.html
        format.json {render json: @ram_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @ram_workload.destroy
    respond_to do |format|
      format.html {redirect_to :back, notice: 'RAM Workload was successfully destroyed.' }
      format.json {head :no_content, status: :deleted}
    end
  end

  private

    def set_ram_workload
      @ram_workload = current_user.ram_workloads.find(params[:id])
    end

    def ram_workload_params
      params.require(:ram_workload).permit(:ingredient_id, :ram_mb_required, :ram_mb_required_user_capacity, :ram_mb_growth_per_user)
    end

end
