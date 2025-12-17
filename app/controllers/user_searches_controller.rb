# frozen_string_literal: true

class UserSearchesController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint_partial UserSearches::Operation::Index, UserSearches::Component::Results, target_id: "user-search-results"
  end
end
