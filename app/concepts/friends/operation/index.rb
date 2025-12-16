# frozen_string_literal: true

class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?

    self.model = policy_scope(Friendship).accepted.includes(:requester, :accepter)
  end
end
