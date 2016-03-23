class Admin::CompaniesController < Admin::AdminController
 before_action :find_company, only: [:edit, :show, :update]

  def new
    @company = BoCompany.new
    @address = []
    @contacts = []
  end


  def index
    @companies = BoCompany.all
  end

  def create
    params[:company][:contacts_attributes] = params[:company][:contacts_attributes].values
    params[:company][:addresses_attributes] = params[:company][:addresses_attributes].values
    @company = BoCompany.new(request: :create, company: params[:company])
    if @company.save
      save_avatar
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
    @users = BoUser.find(:all,params: {company_id: params[:id]}, reload: true)
  end

  def update
    params[:company][:contacts_attributes] = params[:company][:contacts_attributes].values
    params[:company][:addresses_attributes] = params[:company][:addresses_attributes].values
    if @company.update_attributes(request: :update, company: params[:company], reload: true)
      save_avatar
      flash[:success] = 'Company successfully updated!'
    else
      flash[:danger] = 'Company not updated!'
    end
    redirect_to admin_companies_path
  end

  private

  def find_company
    @company = BoCompany.find(params[:id], reload: true)
  end

  def save_avatar
    if params[:company][:avatar]
      puts "sending avatar..."
      url = URI.parse("#{ENV['ORCHARD_BO_API_HOST']}/companies/#{@company.id}")
      req = Net::HTTP::Put::Multipart.new url.path, :avatar => UploadIO.new(File.new(params[:company][:avatar].tempfile), "image/jpeg", "image.jpg")
      req.add_field("Authorization", "Token token=\"#{$user_token}\", app_key=\"#{APP_CONFIG['api_app_key']}\"")
      res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
      end
    end
  end
end
