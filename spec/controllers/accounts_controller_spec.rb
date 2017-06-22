require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  
  describe '#index' do
    it 'should route to the correct path accounts#index' do
      expect(get: '/accounts').to route_to(controller: 'accounts', action: 'index')
    end

    context 'for Add Account Button' do
      it 'should be visibile' do
        sign_in('test@example.com', '12341234')
        VCR.use_cassette('add-account-ability', record: :once) do
          get :index
          expect(response.status).to eq(200)
        end
      end
    end
  end

  # describe '#create' do
    
  #   context 'with valid attribtues' do

  #     let(:params) do 
  #     {
  #       contacts_attributes: {"1462048790": {"type": "phone", "name": "Office", "value": "4168938737"}}, 
  #       name: "Automated Testing Rspec Inc.", 
  #       status_id: "1",
  #       assign_to: "1", 
  #       about: "",
  #       contact_title: "Owner",
  #       addresses_attributes: [{"city": "Port Coquitlam", "country": "CA", "region": "British Columbia", "longitude": "-122.78420699999998", "postcode": "V3C 1T4", "latitude": "49.266014", "street_address": "2492 Kingsway Avenue"}], 
  #       contact_name: "Gurpreet Judge",
  #       quick_facts: "restoration shop"
  #     }
  #     end

  #     it 'should create an account' do
  #       sign_in('test@example.com', '12341234')
  #       # VCR.use_cassette('add-account', record: :once) do
  #         post '/accounts', contact_attribute: params
  #       # response.should redirect_to accounts
  #       # end
  #     end
  #   end
  # end


end
