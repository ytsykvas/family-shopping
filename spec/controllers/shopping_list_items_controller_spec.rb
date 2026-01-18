# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListItemsController, type: :controller do
  let(:owner) { create(:user) }
  let(:member) { create(:user) }
  let(:other_user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }

  before do
    create(:shopping_list_user, shopping_list: shopping_list, user: member)
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        shopping_list_id: shopping_list.id,
        shopping_list_item: { name: "Milk" }
      }
    end

    context "when user is authenticated as owner" do
      before { sign_in owner }

      it "calls endpoint with correct operation" do
        expect(controller).to receive(:endpoint).with(
          ShoppingListItem::Operation::Create
        ).and_call_original
        post :create, params: valid_params
      end

      it "creates a new item" do
        expect do
          post :create, params: valid_params
        end.to change(ShoppingListItem, :count).by(1)
      end

      it "redirects to shopping list" do
        post :create, params: valid_params
        expect(response).to redirect_to("/shopping_lists/#{shopping_list.id}")
      end

      it "sets success notice" do
        post :create, params: valid_params
        expect(flash[:notice]).to eq(I18n.t("shopping_list_items.create.success"))
      end

      it "sets added_by to current user" do
        post :create, params: valid_params
        expect(ShoppingListItem.last.added_by).to eq(owner)
      end
    end

    context "when user is authenticated as member" do
      before { sign_in member }

      it "creates a new item" do
        expect do
          post :create, params: valid_params
        end.to change(ShoppingListItem, :count).by(1)
      end

      it "sets added_by to current user" do
        post :create, params: valid_params
        expect(ShoppingListItem.last.added_by).to eq(member)
      end
    end

    context "when user is not owner or member" do
      before { sign_in other_user }

      it "does not create item" do
        expect do
          post :create, params: valid_params
        end.not_to change(ShoppingListItem, :count)
      end

      it "redirects with authorization error" do
        post :create, params: valid_params
        expect(flash[:alert]).to be_present
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        post :create, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not create item" do
        expect do
          post :create, params: valid_params
        end.not_to change(ShoppingListItem, :count)
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          shopping_list_id: shopping_list.id,
          shopping_list_item: { name: "" }
        }
      end

      before { sign_in owner }

      it "does not create item" do
        expect do
          post :create, params: invalid_params
        end.not_to change(ShoppingListItem, :count)
      end

      it "redirects to shopping list" do
        post :create, params: invalid_params
        expect(response).to redirect_to("/shopping_lists/#{shopping_list.id}")
      end

      it "sets error alert" do
        post :create, params: invalid_params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH #update" do
    let!(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }
    let(:valid_params) do
      {
        shopping_list_id: shopping_list.id,
        id: item.id,
        shopping_list_item: { name: "Updated Name", status: "done" }
      }
    end

    context "when user is authenticated as owner" do
      before { sign_in owner }

      it "calls endpoint with correct operation" do
        expect(controller).to receive(:endpoint).with(
          ShoppingListItem::Operation::Update
        ).and_call_original
        patch :update, params: valid_params
      end

      it "updates the item name" do
        patch :update, params: valid_params
        expect(item.reload.name).to eq("Updated Name")
      end

      it "updates the item status" do
        patch :update, params: valid_params
        expect(item.reload.status).to eq("done")
      end

      it "sets edited_by to current user" do
        patch :update, params: valid_params
        expect(item.reload.edited_by).to eq(owner)
      end

      it "redirects to shopping list" do
        patch :update, params: valid_params
        expect(response).to redirect_to("/shopping_lists/#{shopping_list.id}")
      end

      it "sets success notice" do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq(I18n.t("shopping_list_items.update.success"))
      end
    end

    context "when user is authenticated as member" do
      before { sign_in member }

      it "updates the item" do
        patch :update, params: valid_params
        expect(item.reload.name).to eq("Updated Name")
      end

      it "sets edited_by to current user" do
        patch :update, params: valid_params
        expect(item.reload.edited_by).to eq(member)
      end
    end

    context "when toggling status to done" do
      let(:status_params) do
        {
          shopping_list_id: shopping_list.id,
          id: item.id,
          shopping_list_item: { status: "done" }
        }
      end

      before { sign_in owner }

      it "changes status from pending to done" do
        expect(item.status).to eq("pending")
        patch :update, params: status_params
        expect(item.reload.status).to eq("done")
      end
    end

    context "when toggling status to pending" do
      let!(:done_item) { create(:shopping_list_item, :done, shopping_list: shopping_list, added_by: owner) }
      let(:status_params) do
        {
          shopping_list_id: shopping_list.id,
          id: done_item.id,
          shopping_list_item: { status: "pending" }
        }
      end

      before { sign_in owner }

      it "changes status from done to pending" do
        expect(done_item.status).to eq("done")
        patch :update, params: status_params
        expect(done_item.reload.status).to eq("pending")
      end
    end

    context "when user is not owner or member" do
      before { sign_in other_user }

      it "does not update item" do
        original_name = item.name
        patch :update, params: valid_params
        expect(item.reload.name).to eq(original_name)
      end

      it "redirects with authorization error" do
        patch :update, params: valid_params
        expect(flash[:alert]).to be_present
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        patch :update, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }
    let(:valid_params) do
      {
        shopping_list_id: shopping_list.id,
        id: item.id
      }
    end

    context "when user is authenticated as owner" do
      before { sign_in owner }

      it "calls endpoint with correct operation" do
        expect(controller).to receive(:endpoint).with(
          ShoppingListItem::Operation::Destroy
        ).and_call_original
        delete :destroy, params: valid_params
      end

      it "destroys the item" do
        expect do
          delete :destroy, params: valid_params
        end.to change(ShoppingListItem, :count).by(-1)
      end

      it "redirects to shopping list" do
        delete :destroy, params: valid_params
        expect(response).to redirect_to("/shopping_lists/#{shopping_list.id}")
      end

      it "sets success notice" do
        delete :destroy, params: valid_params
        expect(flash[:notice]).to eq(I18n.t("shopping_list_items.destroy.success"))
      end
    end

    context "when user is authenticated as member" do
      before { sign_in member }

      it "destroys the item" do
        expect do
          delete :destroy, params: valid_params
        end.to change(ShoppingListItem, :count).by(-1)
      end
    end

    context "when user is not owner or member" do
      before { sign_in other_user }

      it "does not destroy item" do
        expect do
          delete :destroy, params: valid_params
        end.not_to change(ShoppingListItem, :count)
      end

      it "redirects with authorization error" do
        delete :destroy, params: valid_params
        expect(flash[:alert]).to be_present
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        delete :destroy, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not destroy item" do
        expect do
          delete :destroy, params: valid_params
        end.not_to change(ShoppingListItem, :count)
      end
    end
  end
end
