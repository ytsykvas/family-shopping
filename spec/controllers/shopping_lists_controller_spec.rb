# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListsController, type: :controller do
  let(:user) { create(:user) }

  describe "GET #index" do
    context "when user is authenticated" do
      before do
        sign_in user
      end

      it "calls endpoint with correct operation and component" do
        expect(controller).to receive(:endpoint).with(
          ShoppingList::Operation::Index,
          ShoppingList::Component::Index
        ).and_call_original
        get :index
      end

      it "returns successful response" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not call endpoint" do
        expect(controller).not_to receive(:endpoint)
        get :index
      end
    end
  end

  describe "POST #create" do
    let(:params) do
      {
        shopping_list: {
          name: "My List"
        }
      }
    end

    context "when user is authenticated" do
      before do
        sign_in user
      end

      it "calls endpoint with correct operation" do
        expect(controller).to receive(:endpoint).with(
          ShoppingList::Operation::Create
        ).and_call_original
        post :create, params: params
      end

      context "with valid params" do
        it "creates a new shopping list" do
          expect do
            post :create, params: params
          end.to change(ShoppingList, :count).by(1)
        end

        it "redirects to index" do
          post :create, params: params
          expect(response).to redirect_to("/shopping_lists")
        end

        it "sets success notice" do
          post :create, params: params
          expect(flash[:notice]).to eq(I18n.t("shopping_lists.create.success"))
        end
      end

      context "with invalid params" do
        let(:invalid_params) do
          {
            shopping_list: {
              name: ""
            }
          }
        end

        it "does not create shopping list" do
          expect do
            post :create, params: invalid_params
          end.not_to change(ShoppingList, :count)
        end

        it "redirects to index" do
          post :create, params: invalid_params
          expect(response).to redirect_to("/shopping_lists")
        end

        it "sets error alert via BaseOperation logic" do
          post :create, params: invalid_params
          # The exact error message depends on validation. 'Name can't be blank' usually.
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        post :create, params: params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not create shopping list" do
        expect do
          post :create, params: params
        end.not_to change(ShoppingList, :count)
      end
    end
  end
end
