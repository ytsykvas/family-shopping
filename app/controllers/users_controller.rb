# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped

  def show
    endpoint Users::Operation::Show, Users::Component::Show
  end
end
