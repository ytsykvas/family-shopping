# frozen_string_literal: true

class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end

  def destroy
    endpoint Friends::Operation::Destroy
  end
end
