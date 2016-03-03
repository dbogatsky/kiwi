class ConversationItem < OrchardApiModel
  self.prefix = "/api/v1/conversations/:conversation_id/"
	self.element_name = "items"
	belongs_to :conversation
	has_many :events, class_name: "ConversationItemEvent"
	CONVERSATION_ITEM_TYPES = ["note", "call", "meeting", "email"]
end
