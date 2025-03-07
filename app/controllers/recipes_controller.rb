class RecipesController < ApplicationController
  def index
    @recipes = Recipe.all
  end

  def search
    if params[:recipe_search].present?
      query = "%#{params[:recipe_search].downcase}%"
      @recipes = Recipe.where("LOWER(name) ILIKE ?", query)
    else
      @recipes = Recipe.all
    end

    respond_to do |format|
      format.turbo_stream { render partial: "recipes/results", locals: { recipes: @recipes } }
      format.html { render "index" }
    end
  end
end
