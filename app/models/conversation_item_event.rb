class ConversationItemEvent < OrchardApiModel
  self.prefix = "/api/v1/conversation_items/:conversation_item_id/"
	self.element_name = "events"
	belongs_to :conversation_item
end
