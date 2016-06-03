class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [:show, :edit, :update, :destroy]

  def index
    @ingredients = Ingredient.page(params[:page])
    @roots = @ingredients.select {|i| is_root(i)}
  end

  def roots
    @roots = Ingredient.select {|i| is_root(i)}
  end

  def show
    @dependency_constraints = dependency_constraints(@ingredient).values
  end

  def new
   @ingredients = Ingredient.all
   @ingredient = if params[:copy]
     Ingredient.find(params[:copy]).deep_dup
   else
     Ingredient.new
   end
  end

  def edit
    @ingredients = Ingredient.all
  end

  def create
    @ingredient = Ingredient.new
    @ingredient.update_attributes(ingredient_params)

    respond_to do |format|
      if @ingredient.save
        format.html { redirect_to @ingredient, notice: 'Ingredient was successfully created.' }
        format.json { render :show, status: :created, location: @ingredient}
      else
        format.html { render :new }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    @ingredient.update_attributes(ingredient_params)

    respond_to do |format|
      if @ingredient.save
        format.html { redirect_to @ingredient, notice: 'Ingredient was successfully updated.' }
        format.json { render :show, status: :ok, location: @ingredient}
      else
        format.html { render :edit }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy

  end



  private

    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end

    def ingredient_params
      params.require(:ingredient).permit(:name,:body,:parent_id, constraints_as_source_attributes: [:id, :ingredient_id, :target_id, :_destroy])
    end

    def dependency_constraints(current_ingredient)
      constraint_hash = {}
      current_ingredient.children.all.each do |child|
        constraint_hash.merge(dependency_constraints(child))
      end

      current_ingredient.constraints_as_source.all.each do |constraint|
        constraint_hash[constraint.id] = constraint
      end
      current_ingredient.constraints_as_target.all.each do |constraint|
        constraint_hash[constraint.id] = constraint
      end

      return constraint_hash
    end

end
