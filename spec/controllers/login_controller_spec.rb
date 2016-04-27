require 'rails_helper'

RSpec.describe LoginController, type: :controller do
  describe 'login' do
    it 'should route to the correct path login#login' do
      expect(post: '/login').to route_to(controller: 'login', action: 'login')
    end

    context 'With a valid credientials' do
      it 'should login the user' do
        VCR.use_cassette('login-success', record: :once) do
          post :login, email: 'test@example.com', password: '12341234'
          expect(response.status).to eq(302)
          expect(flash[:danger]).to eq(nil)
        end
      end

      it 'should redirect to dashboard' do
        VCR.use_cassette('login-success', record: :once) do
          post :login, email: 'test@example.com', password: '12341234'
          expect(response).to redirect_to(dashboard_path)
        end
      end
    end

    context 'With invalid credentials' do
      it 'shoudl not login' do
        VCR.use_cassette('login-failure', record: :once) do
          post :login, email: 'test@example.com', password: '1'
          expect(response.status).to eq(302)
          expect(flash[:danger]).to eq('Your email or password is incorrect. Please try again.')
        end
      end

      it 'should redirect back to login' do
        VCR.use_cassette('login-failure', record: :once) do
          post :login, email: 'test@example.com', password: '1'
          expect(response).to redirect_to(user_login_path)
        end
      end
    end
  end
end
