class UserAccountSharing < OrchardApiModel
  belongs_to :account

  schema do
    attribute 'id', :string
    attribute 'permission', :string
  end

end

