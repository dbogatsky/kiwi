class ConversationItemEvent < OrchardApiModel
	self.site = "#{ENV.fetch("ORCHARD_API_HOST")}/conversation_items/:conversation_item_id/"
	self.element_name = "events"
	belongs_to :conversation_item
end