class ConveControll. .. 

  def show
    @account = Account.find(params[:account_id])
    @conversation = @account.conversation
  end
end
