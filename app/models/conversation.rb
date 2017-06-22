class Conversation < OrchardApiModel
	self.prefix = "/accounts/:account_id/"
	belongs_to :account
	has_many :conversation_items
end
