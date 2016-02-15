class CompanyEntitiesController < ApplicationController

	def new
		@company_entity = CompanyEntities.new
	end

	def create
	  @company_entity = CompanyEntities.new(request: :create, company_entity: params[:company_entity])
    if @company_entity.save
    	flash[:success] = 'Company Entity successfully created.'
      redirect_to company_path
    else
    	flash[:danger] = 'Company Entity could not created.'
    	redirect_to company_path
    end
	end

	def update
		@entity = CompanyEntities.find(params[:id])
		if @entity.update_attributes(request: :update, company_entity: params[:company_entity])
      flash[:success] = 'Company Entity successfully updated.'
      redirect_to company_path
    else
    	flash[:danger] = 'Company Entity could not updated.'
    	redirect_to company_path
    end
	end

	def show
		@entity = CompanyEntities.find(params[:id])
	end

	def destroy
		@entity = CompanyEntities.find(params[:id])
		if @entity.destroy
			flash[:success] = 'Company Entity successfully deleted.'
		  redirect_to company_path
		 else
		 	flash[:danger]  = 'Company Entity could not deleted.'
		 	redirect_to company_path
		 end
	end
end
