class Conversation < OrchardApiModel
	  self.site = "http://#{RequestStore.store[:tenant]}-api.code10.ca/api/v1/accounts/:account_id/"
	belongs_to :account
	has_many :conversation_items
end