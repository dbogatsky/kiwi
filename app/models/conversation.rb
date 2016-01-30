class Conversation < OrchardApiModel
	self.site = "#{ENV.fetch("ORCHARD_API_HOST")}/accounts/:account_id/"
	belongs_to :account
	has_many :conversation_items
end