class UserAccountSharing < OrchardApiModel
  belongs_to :account

  schema do
    attribute 'user_id', :string
    attribute 'permission', :string
  end
end
