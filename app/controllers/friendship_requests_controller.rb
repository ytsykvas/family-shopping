# frozen_string_literal: true

class FriendshipRequestsController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint FriendshipRequest::Operation::Index, FriendshipRequest::Component::Index
  end

  def create
    endpoint FriendshipRequest::Operation::Create
  end

  def update
    endpoint FriendshipRequest::Operation::Update
  end

  def destroy
    endpoint FriendshipRequest::Operation::Destroy
  end
end
