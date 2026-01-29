require 'rails_helper'

describe GlobalRecipePolicy do
  subject { described_class.new(user, :global_recipe) }

  let(:user) { create(:user) }

  it { is_expected.to permit_action(:index) }
  it { is_expected.to permit_action(:show) }
  it { is_expected.to permit_action(:add) }
end
