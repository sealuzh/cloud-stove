class IngredientsController < ApplicationController
  before_action :set_ingredient_from_admin, only: [:show, :instance, :instances]
  before_action :set_ingredient, only: [:edit, :update, :destroy, :copy, :template]
  skip_before_action :authenticate_user!, only: [:templates]
  before_action :authenticate_admin!, only: [:template, :new, :create, :instances]

  # Returns all ingredients (irrespective if template, instance, application) of the current user
  def index
    @ingredients = current_user.ingredients.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: @ingredients}
    end
  end

  # Returns applications defined by the current user
  def applications
    @roots = current_user.ingredients.select {|i| i.application_root? && !i.is_template}

    respond_to do |format|
      format.html
      format.json {render json: @roots}
    end
  end

  # Returns all templates, independent of user
  def templates
    @templates = Ingredient.select {|i| i.application_root? && i.is_template}

    respond_to do |format|
      format.html
      format.json {render json: @templates}
    end
  end

  # Returns instances of the template with root ingredient given by params[:ingredient_id]
  def instances
    ensure_ingredient_present; return if performed?
    ensure_application_root; return if performed?
    ensure_template; return if performed?

    @instances = @ingredient.instances
    respond_to do |format|
      format.html
      format.json {render json: @instances}
    end
  end

  # returns the details of the ingredient determined by params[:id]
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

  # copies an entire hierarchy starting at the root determined by params[:ingredient_id]
  def copy
    ensure_ingredient_present; return if performed?

    copy = @ingredient.copy
    respond_to do |format|
      format.html {redirect_to copy, notice: 'Ingredient hierarchy was successfully copied.'}
      format.json {render json: copy, status: :ok}
    end
  end

  # makes a template out of an hierarchy starting at the root determined by params[:ingredient_id]
  def template
    ensure_ingredient_present; return if performed?
    ensure_application_root; return if performed?
    ensure_no_template; return if performed?

    template = @ingredient.make_template
    respond_to do |format|
      format.html {redirect_to template, notice: 'Template was successfully created.'}
      format.json {render json: template, status: :ok}
    end
  end

  def instance
    ensure_ingredient_present; return if performed?
    ensure_application_root; return if performed?
    ensure_template; return if performed?

    new_instance = @ingredient.instantiate(current_user)
    if new_instance
      respond_to do |format|
        format.html {redirect_to new_instance, notice: 'Template was successfully instantiated.'}
        format.json {render json: new_instance, status: :ok}
      end
    else
      respond_to do |format|
        format.html {redirect_to :back, notice: 'Can only instantiate root template ingredients.'}
        format.json {render json: 'Can only instantiate root template ingredients.', status: :unprocessable_entity}
      end
    end
  end

  def new
   @ingredients = current_user.ingredients
   @ingredient = if params[:copy]
     current_user.ingredients.find(params[:copy]).deep_dup
   else
     Ingredient.new
   end
  end

  def edit
    @ingredients = current_user.ingredients.all # the list of ingredients usable as a parent
  end

  def create
    @ingredients = current_user.ingredients
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
    @ingredients = current_user.ingredients
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

  def destroy
    ensure_no_template; return if performed?

    @ingredient.destroy
    respond_to do |format|
      format.html { redirect_to ingredients_url, notice: 'Ingredient and its subtree was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

    def set_ingredient_from_admin
      id = params[:id] || params[:ingredient_id]
      @ingredient = set_ingredient || User.stove_admin.ingredients.find_by_id(id)
    end

    def set_ingredient
      id = params[:id] || params[:ingredient_id]
      @ingredient = current_user.ingredients.find_by_id(id)
    end

    def ensure_ingredient_present
      if @ingredient.nil?
        respond_to do |format|
          format.html {redirect_to :templates, notice: 'Ingredient not found.'}
          format.json {render json: 'Ingredient not found.', status: :not_found}
        end
      end
    end

    def ensure_application_root
      unless @ingredient.application_root?
        respond_to do |format|
          format.html { redirect_to :back, notice: 'Ingredient must be an application root.' }
          format.json { render json: 'Ingredient must be an application root.', status: :unprocessable_entity }
        end
      end
    end

    def ensure_template
      unless @ingredient.is_template
        respond_to do |format|
          format.html {redirect_to :back, notice: 'Ingredient must be a template.'}
          format.json {render json: 'Ingredient must be a template.', status: :unprocessable_entity}
        end
      end
    end

    def ensure_no_template
      if @ingredient.is_template
        respond_to do |format|
          format.html {redirect_to :back, notice: 'Ingredient must be a non-template.'}
          format.json {render json: 'Ingredient must be a non-template.', status: :unprocessable_entity}
        end
      end
    end

    def ingredient_params
      if @ingredient.application_root?
        params.require(:ingredient).permit(:name,:body,:parent_id,
                                           cpu_workload_attributes: [:id, :ingredient_id, :cspu_user_capacity, :parallelism, :_destroy],
                                           ram_workload_attributes: [:id, :ingredient_id, :ram_mb_required, :ram_mb_required_user_capacity, :ram_mb_growth_per_user, :_destroy],
                                           constraints_as_source_attributes: [:id, :ingredient_id, :target_id, :_destroy],
                                           ram_constraint_attributes:[:id, :ingredient_id, :min_ram, :_destroy],
                                           cpu_constraint_attributes:[:id, :ingredient_id, :min_cpus, :_destroy],
                                           preferred_region_area_constraint_attributes:[:id, :ingredient_id, :preferred_region_area, :_destroy],
                                           provider_constraint_attributes:[:id, :ingredient_id, :preferred_providers, :_destroy])
      else
        params.require(:ingredient).permit(:name,:body,:parent_id,
                                           cpu_workload_attributes: [:id, :ingredient_id, :cspu_user_capacity, :parallelism, :_destroy],
                                           ram_workload_attributes: [:id, :ingredient_id, :ram_mb_required, :ram_mb_required_user_capacity, :ram_mb_growth_per_user, :_destroy],
                                           constraints_as_source_attributes: [:id, :ingredient_id, :target_id, :_destroy],
                                           ram_constraint_attributes:[:id, :ingredient_id, :min_ram, :_destroy],
                                           cpu_constraint_attributes:[:id, :ingredient_id, :min_cpus, :_destroy],
                                           preferred_region_area_constraint_attributes:[:id, :ingredient_id, :preferred_region_area, :_destroy])
      end
    end
end
