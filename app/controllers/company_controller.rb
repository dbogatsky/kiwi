class CompanyController < ApplicationController
	# Leaving this here for now
	before_action :superadmin, only: [:index]


	def index
		# Main Company Page

	end


	def add
		# Add new Company

	end


	def edit
		# Edit Company

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

	def delete
		# Delete Company (Soft delete)

		flash[:success] = 'Company deleted successfully'
		redirect_to company_path

		#flash[:danger] = 'Warning: Can not delete company.  Please contact the administator for assistance.'  #  Unable to delete company
		# Record the API error into the log.  Action with timestamp
	end


	private


	def superadmin
		@superadmin = true
	end
			
end
