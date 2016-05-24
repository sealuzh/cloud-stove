class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [:show, :edit, :update, :destroy]

  def index
    @ingredients = Ingredient.page(params[:page])
    @roots = @ingredients.select {|i| is_root(i)}
  end

  def show

  end

  def new

  end

  def edit

  end

  def destroy

  end



  private

    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end

end
