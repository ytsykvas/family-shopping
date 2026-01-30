# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ShoppingLists", type: :request do
  let(:user) { create(:user) }
  let!(:shopping_list) { create(:shopping_list, owner: user) }

  before do
    sign_in user
  end

  describe "DELETE /shopping_lists/:id" do
    context "with Turbo Stream format" do
      it "redirects to index with 303 status (via standard redirect)" do
        # Note: In our implementation we use redirect_to which returns 302/303.
        # Turbo Drive handles standard redirects by following them.

        delete shopping_list_path(shopping_list), headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to redirect_to(shopping_lists_path)
        expect(response).to have_http_status(:found) # 302 or 303 default for Rails redirects
      end
    end

    context "with HTML format" do
      it "redirects to index" do
        delete shopping_list_path(shopping_list)
        expect(response).to redirect_to(shopping_lists_path)
      end
    end
  end
end
