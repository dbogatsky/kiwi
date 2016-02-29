class ConversationItem < OrchardApiModel
	self.site = "#{ENV.fetch("ORCHARD_API_HOST")}/conversations/:conversation_id/"
	self.element_name = "items"
	belongs_to :conversation
	has_many :events, class_name: "ConversationItemEvent"
	CONVERSATION_ITEM_TYPES = ["note", "call", "meeting", "email"]
end