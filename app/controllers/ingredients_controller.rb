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
    @roots = Ingredient.select {|i| i.is_root && !i.is_template}

    respond_to do |format|
      format.html
      format.json {render json: @roots}
    end
  end

  def templates
    @templates = Ingredient.select {|i| i.is_root && i.is_template}

    respond_to do |format|
      format.html
      format.json {render json: @templates}
    end
  end

  def instances
    i = Ingredient.find_by(id: params[:ingredient_id])
    if i
      if i.is_root && i.is_template
        @instances = i.instances
        respond_to do |format|
          format.html
          format.json {render json: @instances}
        end
      else
        respond_to do |format|
          format.html {redirect_to :back, notice: 'Ingredient must be root and a template.'}
          format.json {render json: 'Ingredient must be root and a template.', status: :forbidden}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to :templates, notice: 'Template not found.'}
        format.json {render json: 'Template not found.', status: :not_found}
      end
    end
  end

  def show
    @cpu_constraint = @ingredient.cpu_constraint
    @ram_constraint = @ingredient.ram_constraint
    @region_constraint = @ingredient.preferred_region_area_constraint
    @dependency_constraints = @ingredient.all_dependency_constraints
    @provider_constraint = @ingredient.provider_constraint
    @deployment_recommendation = @ingredient.deployment_recommendations.last.embed_ingredients unless @ingredient.deployment_recommendations.empty?
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

  def template
    i = Ingredient.find(params[:ingredient_id]).make_template
    if i
      respond_to do |format|
        format.html {redirect_to i, notice: 'Template was successfully created.'}
        format.json {render json: i, status: :ok}
      end
    else
      respond_to do |format|
        format.html {redirect_to :back, notice: 'Can only make templates out of root non-template ingredients.'}
        format.json {render json: 'Can only make templates out of root non-template ingredients..', status: :forbidden}
      end
    end
  end

  def instance
    i = Ingredient.find(params[:ingredient_id]).instantiate
    if i
      respond_to do |format|
        format.html {redirect_to i, notice: 'Template was successfully instantiated.'}
        format.json {render json: i, status: :ok}
      end
    else
      respond_to do |format|
        format.html {redirect_to :back, notice: 'Can only instantiate root template ingredients.'}
        format.json {render json: 'Can only instantiate root template ingredients.', status: :forbidden}
      end
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
                                         cpu_constraint_attributes:[:id, :ingredient_id, :min_cpus, :_destroy],
                                         preferred_region_area_constraint_attributes:[:id, :ingredient_id, :preferred_region_area, :_destroy],
                                         provider_constraint_attributes:[:id, :ingredient_id, :preferred_providers, :_destroy])
    end

end
