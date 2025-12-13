# frozen_string_literal: true

module Api
  module V1
    class UsersController < ActionController::API
      def check_nickname
        nickname = params[:nickname]

        if nickname.blank?
          render json: { available: false, message: I18n.t("api.users.nickname_required") }, status: :ok
          return
        end

        exists = User.where("lower(nickname) = ?", nickname.downcase).exists?

        if exists
          render json: { available: false, message: I18n.t("api.users.nickname_taken") }, status: :ok
        else
          render json: { available: true, message: I18n.t("api.users.nickname_available") }, status: :ok
        end
      end

      def check_email
        email = params[:email]

        if email.blank?
          render json: { available: false, message: I18n.t("api.users.email_required") }, status: :ok
          return
        end

        # Basic email format validation
        unless email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
          render json: { available: false, message: I18n.t("api.users.email_invalid") }, status: :ok
          return
        end

        exists = User.where("lower(email) = ?", email.downcase).exists?

        if exists
          render json: { available: false, message: I18n.t("api.users.email_taken") }, status: :ok
        else
          render json: { available: true, message: I18n.t("api.users.email_available") }, status: :ok
        end
      end
    end
  end
end
