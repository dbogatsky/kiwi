class CompanyController < ApplicationController
  load_and_authorize_resource

  def index
    #comapny details
    @company = Company.find(uid: RequestStore.store[:tenant])

    #lets get a fresh batch of Entities and Statues, not from cache
    @entites = CompanyEntity.all(uid: RequestStore.store[:tenant], reload: true)
    @account_statuses = AccountStatus.all(uid: RequestStore.store[:tenant], reload: true)
  end

  def edit_entity
    # Edit entity
  end

  def save
    # Save changes from Add/Edit Company page
    flash[:success] = 'You changes have been successfully saved'
    redirect_to company_path

    #flash[:danger] = 'Warning: Your changes can not be saved.  Please contact the administator for assistance.'  # Unable to save changes
    # Record the API error into the log.  Action with timestamp
  end

  def display_sub_entites
    @entity = CompanyEntity.find(params[:id])
    @sub_entites = @entity.descendants
  end

  def account_status
    # Save changes from Add/Edit Account Statuses page

    if params["account-status-id"].blank?
      @status = AccountStatus.new
      @status.name = params["account-status-name"]
      @status.color  = params["account-status-color"]
      @status.description = params["account-status-desc"]

      # Create new account status
      if @status.save
        #update status list stored in session
        @account_statuses = AccountStatus.all(uid: RequestStore.store[:tenant], :reload => true)
        #session["account"]["statuses"] = @account_statuses

        flash[:success] = 'Account status has been added successfully'
      else
        # Create an error message
        flash[:danger] = 'Ops! Unable to add the account status.  It may have been previously created and deleted, check with your Admin.'  # Log in error message
      end
    else
      # Edit account status
      @status = AccountStatus.find(params["account-status-id"])
      attributes = {:name => params["account-status-name"], :color  => params["account-status-color"], :description =>params["account-status-desc"]}

      #AccountStatus.update_attributes(@status)

      if @status.update_attributes(attributes)

        #update status list stored in session
        @account_statuses = AccountStatus.all(uid: RequestStore.store[:tenant], :reload => true)
        #session["account"]["statuses"] = @account_statuses

        flash[:success] = 'Account status has been edited successfully'
      else
        # Create an error message
        flash[:danger] = 'Ops! Unable to edit the account status'  # Log in error message
      end
    end

    redirect_to company_path
  end

  def get_users
    email_json = []
    User.all.each do |user|
      if user.email.include?(params[:term])
        email_json << {email: user.email, value: user.email}
      end
    end
    render json: email_json
  end

end
