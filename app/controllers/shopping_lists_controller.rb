# frozen_string_literal: true


class ShoppingListsController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint ShoppingList::Operation::Index, ShoppingList::Component::Index
  end

  def show
  end

  def create
    endpoint ShoppingList::Operation::Create
  end

  def update
    endpoint ShoppingList::Operation::Update
  end

  def destroy
    endpoint ShoppingList::Operation::Destroy
  end
end
