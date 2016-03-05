class CompanyEntitiesController < ApplicationController

	def new
		@company_entity = CompanyEntity.new
	end

	def create
	  @company_entity = CompanyEntity.new(request: :create, company_entity: params[:company_entity])
    if @company_entity.save
    	flash[:success] = 'Company Entity successfully created.'

      #Refresh the company entities list stored in cache resource
      @entites = CompanyEntity.all(:reload => true)
      redirect_to company_path
    else
    	flash[:danger] = 'Company Entity could not created.'
    	redirect_to company_path
    end
	end

	def update
		@entity = CompanyEntity.find(params[:id])
		if @entity.update_attributes(request: :update, company_entity: params[:company_entity])
      flash[:success] = 'Company Entity successfully updated.'

      #Refresh the company entities list stored in cache resource
      @entites = CompanyEntity.all(:reload => true)
      redirect_to company_path
    else
    	flash[:danger] = 'Company Entity could not updated.'
    	redirect_to company_path
    end
	end

	def show
		@entity = CompanyEntity.find(params[:id])
	end

	def destroy
		@entity = CompanyEntity.find(params[:id])
		if @entity.destroy
			flash[:success] = 'Company Entity successfully deleted.'

      #Refresh the company entities list stored in cache resource
      @entites = CompanyEntity.all(:reload => true)
		  redirect_to company_path
		 else
		 	flash[:danger]  = 'Company Entity could not deleted.'
		 	redirect_to company_path
		 end
	end
end
