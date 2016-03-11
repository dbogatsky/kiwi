class ConversationItemSearch < OrchardApiModel
  self.prefix = "/api/v1/conversation_items/"
  self.collection_name = "search"
  belongs_to :conversation_item
end