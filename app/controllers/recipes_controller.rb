class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint Recipe::Operation::Index, Recipe::Component::Index
  end

  def show
    endpoint Recipe::Operation::Show, Recipe::Component::Show
  end

  def new
    endpoint Recipe::Operation::New, Recipe::Component::New
  end

  def create
    endpoint Recipe::Operation::Create, Recipe::Component::New
  end

  def destroy
    endpoint Recipe::Operation::Destroy
  end
end
