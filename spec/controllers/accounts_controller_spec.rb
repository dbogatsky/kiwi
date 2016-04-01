require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  describe "GET #index" do
    before do
    	# user = {}
    	# params[:user][:email] = 'acb@gmail.com'
    	# params[:user][:first_name] = 'asdkjkhj'
    	# params[:user][:last_name] = 'allllll'
    	# params[:user][:password] = '12341234'
    	# params[:user][:password_confirmation] = '12341234'

     #  @user  = User.new(request: :create, user: {email: 'acb@gmail.com', first_name: 'asdkjkhj', last_name: 'allllll', password: '12341234', password_confirmation: '12341234'  })
    end
    it "should return all accounts" do
    	# xhr :get,:index
    	get :index

    end
  end
end
