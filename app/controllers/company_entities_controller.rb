class CompanyEntitiesController < ApplicationController

	def new
		@company_entity = CompanyEntities.new
	end

	def create
	  @company_entity = CompanyEntities.new(params[:company_entity])
    if @company_entity.save
      redirect_to company_path, notice: 'Company Entity successfully created.'
    else
    	redirect_to company_path, alert: 'Company Entity could not created.'
    end
	end

	def update
		@entity = CompanyEntities.find(params[:id])
		if @entity.update_attributes(params[:company_entity])
       redirect_to company_path, notice: 'Company Entity successfully updated.'
    else
    		redirect_to company_path, notice: 'Company Entity could not updated.'
    end
	end

	def show
		@entity = CompanyEntities.find(params[:id])
	end

	def destroy
		@entity = CompanyEntities.find(params[:id])
		if @entity.destroy
		   redirect_to company_path, notice: 'Company Entity successfully deleted.'
		 else
		 	redirect_to company_path, notice: 'Company Entity could not deleted.'
		 end
	end
end
