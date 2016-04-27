require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  describe "#index" do

    it 'should route to the correct path accounts#index' do
      expect(get: '/accounts').to route_to(controller: 'accounts', action: 'index')
    end


    context 'for Add Account Button' do
      it 'should be visibile' do
        sign_in("test@example.com", "12341234")
        VCR.use_cassette('add-account-ability', record: :once) do
          get :index
          expect(response.status).to eq(200)
        end
      end
    end



  end
end
