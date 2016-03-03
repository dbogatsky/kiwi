class ConversationItemEvent < OrchardApiModel
	  self.site = "http://#{RequestStore.store[:tenant]}-api.code10.ca/api/v1/:conversation_item_id/"
	self.element_name = "events"
	belongs_to :conversation_item
end