class Admin::CompaniesController < Admin::AdminController


  def new
    @company = Company.new
  end


  def index
    @companies = Company.all
  end

  def create
   #  binding.pry
  	# params[:company][:contacts_attributes] = params[:company][:contacts_attributes].values
   #  params[:company][:addresses_attributes] = params[:company][:addresses_attributes].values
   #  @company = Company.new(request: :create, company: params[:company])
    # url = URI.parse("http://api.convo.code10.ca/backoffice/companies")
    # http = Net::HTTP.new(url.host)
    # response = Net::HTTP.post_form(url, params[:company])
  end

  def edit
    @company = Company.all.last
  end
end
