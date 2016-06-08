class ConstraintsController < ApplicationController

  before_action :set_dependency_constraint, only: [:show, :destroy]


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
      format.html
      format.json {render json: @constraint, status: :created}
    end
  end

  def destroy
    @constraint.destroy
    respond_to do |format|
      format.html
      format.json {head :no_content, status: :deleted}
    end
  end

  private

    def set_dependency_constraint
      @constraint = Constraint.find(params[:id])
    end

    def constraint_params
      params.permit(:type, :ingredient_id, :target_id, :source_id)
    end

    def deserialize_to_constraint
      type = constraint_params[:type]
      constraint_clazz = type.constantize
      constraint_instance = constraint_clazz.new
      constraint_instance.update_attributes(constraint_params)
    end
end