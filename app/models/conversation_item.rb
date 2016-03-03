class ConversationItem < OrchardApiModel
  self.site = "http://#{RequestStore.store[:tenant]}-api.code10.ca/api/v1/conversations/:conversation_id/"
	self.element_name = "items"
	belongs_to :conversation
	has_many :events, class_name: "ConversationItemEvent"
	CONVERSATION_ITEM_TYPES = ["note", "call", "meeting", "email"]
end