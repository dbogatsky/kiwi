class QuickStats < OrchardApiModel
  include ActiveResource::Singleton
  self.prefix = "/api/v1/"
  self.collection_name = "quick_stats"
end