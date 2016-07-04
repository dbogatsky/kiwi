class OrchardApiCollection < ActiveResource::Collection

  attr_accessor :meta, :paginatable
  def initialize(parsed = {})
    @meta = parsed.delete("meta")
    @elements = parsed.kind_of?(Hash) ? parsed.values[0] : parsed
    setup_pagination
  end

  def setup_pagination
    return if @meta.nil?
    @paginatable ||= WillPaginate::Collection.new(@meta["current_page"], @meta["per_page"], @meta["total_entries"]) 
  end

  def method_missing(method, *args, &block)
    if @paginatable.respond_to?(method)
      @paginatable.send(method)
    else
      super
    end
  end
end
