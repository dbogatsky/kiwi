class CompanyController < ApplicationController
	# Leaving this here for now
	before_action :superadmin, only: [:index]


	def index
		# Main Company Page
		@account_statuses = Account.statuslist
	end


	def add_entity
		# Add new entity

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

	def account_status
		
		if ( params["account-status-id"].blank? ) 

			# Create new account status
			if Account.statusadd(params["account-status-name"],params["account-status-color"],params["account-status-desc"])
				flash[:success] = 'Account status has been added successfully'
			else 
				# Create an error message
				flash[:danger] = 'Ops! Unable to add the account status'  # Log in error message  
			end

		else

			# Edit account status
			if Account.statusedit(params["account-status-id"],params["account-status-name"],params["account-status-color"],params["account-status-desc"])
				flash[:success] = 'Account status has been edited successfully'
			else 
				# Create an error message
				flash[:danger] = 'Ops! Unable to edit the account status'  # Log in error message  
			end			


		end

		redirect_to company_path	
	end





	private

		def superadmin
			@superadmin = true
		end
			
end
