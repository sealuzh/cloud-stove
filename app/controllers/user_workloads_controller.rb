class UserWorkloadsController < ApplicationController
  before_action :set_user_workload, only: [:show, :update, :destroy]

  def index
    @user_workloads = UserWorkload.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @user_workloads, status: :ok}
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json {render json: @user_workload, status: :ok}
    end
  end

  def new
    @user_workload = if params[:copy]
      UserWorkload.find(params[:copy]).deep_dup
    else
      UserWorkload.new
    end
  end

  def create
    @user_workload = UserWorkload.new
    @user_workload.update_attributes(user_workload_params)
    respond_to do |format|
      if @user_workload.save!
        format.html {redirect_to @user_workload, success: 'User Workload was successfully created!'}
        format.json {render json: @user_workload, status: :created}
      else
        format.html
        format.json {render json: @user_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def edit
    @user_workload = UserWorkload.find(params[:id])
  end

  def update
    respond_to do |format|
      if @user_workload.update(user_workload_params)
        format.html {redirect_to @user_workload, success: 'User Workload was successfully updated!'}
        format.json {render json: @user_workload, status: :ok}
      else
        format.html {render 'edit'}
        format.json {render json: @user_workload.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @user_workload.destroy
    respond_to do |format|
      format.html {redirect_to :back, success: 'User Workload was successfully destroyed.' }
      format.json {head :no_content, status: :deleted}
    end
  end

  private
    def set_user_workload
      @user_workload = UserWorkload.find(params[:id])
    end

    def user_workload_params
      params.require(:user_workload).permit(:num_simultaneous_users, :ingredient_id)
    end
end
