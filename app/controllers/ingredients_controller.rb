class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [:show, :edit, :update, :destroy]

  def index
    @ingredients = Ingredient.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @ingredients}
    end
  end

  def applications
    @roots = Ingredient.select {|i| i.is_root}

    respond_to do |format|
      format.html
      format.json {render json: @roots}
    end
  end

  def show
    @cpu_constraint = @ingredient.cpu_constraint
    @ram_constraint = @ingredient.ram_constraint
    @dependency_constraints = @ingredient.all_dependency_constraints
    @deployment_recommendation = @ingredient.deployment_recommendation.embed_ingredients unless @ingredient.deployment_recommendation.nil?
    respond_to do |format|
      format.html
      format.json {render json: @ingredient}
    end
  end

  def copy
    i = Ingredient.find(params[:ingredient_id]).copy
    respond_to do |format|
      format.html {redirect_to i, notice: 'Ingredient hierarchy was successfully copied.'}
      format.json {render json: i, status: :ok}
    end
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
    @ingredients = Ingredient.all
    @ingredient = Ingredient.new
    @ingredient.update_attributes(ingredient_params)

    respond_to do |format|
      if @ingredient.save
        format.html { redirect_to @ingredient, notice: 'Ingredient was successfully created.' }
        format.json { render json: @ingredient, status: :created}
      else
        format.html { render :new }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @ingredients = Ingredient.all
    @ingredient.update_attributes(ingredient_params)

    respond_to do |format|
      if @ingredient.save
        format.html { redirect_to @ingredient, notice: 'Ingredient was successfully updated.' }
        format.json { render json: @ingredient, status: :ok}
      else
        format.html { render :edit }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /blueprints/1
  # DELETE /blueprints/1.json
  def destroy
    if @ingredient.is_template
      respond_to do |format|
        format.html { redirect_to ingredients_url, notice: "Can't destroy a template ingredient." }
        format.json { render json: "Can't destroy a template ingredient.", status: :forbidden}
      end
    else
      @ingredient.destroy
      respond_to do |format|
        format.html { redirect_to ingredients_url, notice: 'Ingredient and its subtree was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private

    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end

    def ingredient_params
      params.require(:ingredient).permit(:name,:body,:parent_id,
                                         constraints_as_source_attributes: [:id, :ingredient_id, :target_id, :_destroy],
                                         ram_constraint_attributes:[:id, :ingredient_id, :min_ram, :_destroy],
                                         cpu_constraint_attributes:[:id, :ingredient_id, :min_cpus, :_destroy])
    end

end
