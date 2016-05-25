class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [:show, :edit, :update, :destroy]

  def index
    @ingredients = Ingredient.page(params[:page])
    @roots = @ingredients.select {|i| is_root(i)}
  end

  def show

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

  def destroy

  end



  private

    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end

    def ingredient_params
      params.require(:ingredient).permit(:name,:body,:parent_id)
    end

end
