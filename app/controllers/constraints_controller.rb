class ConstraintsController < ApplicationController

  before_action :set_constraint, only: [:show, :destroy, :update]


  def show
    respond_to do |format|
      format.html
      format.json {render json: @constraint, status: :ok}
    end
  end

  def index
    @constraints = Constraint.page(params[:page])
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
      params = constraint_params
      if params[:preferred_providers].present?
        params[:preferred_providers] = constraint_params[:preferred_providers].join(',')
      end
      if @constraint.update(params)
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
      @constraint = Constraint.find(params[:id])
    end

    def constraint_params
      params.permit(:type, :ingredient_id, :target_id, :source_id, :min_ram, :min_cpus, :preferred_region_area, :preferred_providers =>[])
    end

    def deserialize_to_constraint
      type = constraint_params[:type]
      
      if type == 'ProviderConstraint'
        constraint_clazz = type.constantize
        constraint_instance = constraint_clazz.new
        constraint_instance.ingredient_id = constraint_params[:ingredient_id]
        constraint_instance.preferred_providers = constraint_params[:preferred_providers].join(',')
        constraint_instance
      else
        constraint_clazz = type.constantize
        constraint_instance = constraint_clazz.new
        constraint_instance.assign_attributes(constraint_params)
        constraint_instance
      end
    end
end
