class ConversationItemEvent < OrchardApiModel
  self.prefix = "/conversation_items/:conversation_item_id/"
	self.element_name = "events"
	belongs_to :conversation_item
end
