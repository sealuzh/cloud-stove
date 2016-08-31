class ConstraintsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_constraint, only: [:show, :destroy, :update]


  def show
    respond_to do |format|
      format.html
      format.json {render json: @constraint, status: :ok}
    end
  end

  def index
    @constraints = current_user.constraints.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @constraints, status: :ok}
    end
  end

  def create
    @constraint = deserialize_to_constraint
    respond_to do |format|
      if @constraint.save!
        format.html
        format.json {render json: @constraint, status: :created}
      else
        format.html
        format.json {render json: @constraint.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @constraint.update(constraint_params)
        format.html
        format.json {render json: @constraint, status: :ok}
      else
        format.html
        format.json {render json: @constraint.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @constraint.destroy
    respond_to do |format|
      format.html {redirect_to :back, notice: 'Constraint was successfully destroyed.' }
      format.json {head :no_content, status: :deleted}
    end
  end

  private

    def set_constraint
      @constraint = current_user.constraints.find(params[:id])
    end

    def constraint_params
      p = params.permit(:type, :ingredient_id, :target_id, :source_id, :min_ram, :min_cpus, :preferred_region_area, :preferred_providers =>[])
      if p[:type] == 'ProviderConstraint'
        p[:preferred_providers] = p[:preferred_providers].join(',')
      end
      p
    end

    def deserialize_to_constraint
      type = constraint_params[:type]
      constraint_clazz = type.constantize
      constraint_instance = constraint_clazz.new
      constraint_instance.assign_attributes(constraint_params)
      constraint_instance.user = current_user
      constraint_instance
    end
end
