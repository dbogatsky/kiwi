class Admin::CompaniesController < Admin::AdminController
 before_action :find_company, only: [:edit, :show, :update]

  def new
    @company = Company.new
    @address = []
    @contacts = []
  end


  def index
    @companies = Company.all
  end

  def create
  	params[:company][:contacts_attributes] = params[:company][:contacts_attributes].values
    params[:company][:addresses_attributes] = params[:company][:addresses_attributes].values
    @company = Company.new(request: :create, company: params[:company])
    if @company.save
      flash[:success] = 'Company successfully created.'
      redirect_to admin_companies_path
    else
      flash[:danger] = 'Company could not created.'
      redirect_to new_admin_company_path
    end
  end

  def edit
    @address = @company.addresses.last
    @contacts = @company.contacts
  end

  def show
  end

  def update
    params[:company][:contacts_attributes] = params[:company][:contacts_attributes].values
    params[:company][:addresses_attributes] = params[:company][:addresses_attributes].values
    if @company.update_attributes(request: :update, company: params[:company], reload: true)
      flash[:success] = 'Company successfully updated!'
    else
      flash[:danger] = 'Company not updated!'
    end
    redirect_to admin_companies_path
  end

  private

  def find_company
    @company = Company.find(params[:id], reload: true)
  end
end
