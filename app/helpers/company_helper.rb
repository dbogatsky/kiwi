module CompanyHelper

  def nested_entities(entites)
    z = []
    parents = entites.collect{|a| a if a.parent == nil}.compact
    level = 0
    set_items(parents, level, z)
    z.map do |hash|
      if hash[:level] > 1
        padding = 10 * hash[:level].to_i
      end
      content_tag(:ul, render('company/entity', entity: hash[:entity]),
          class: "table_head table_content level_#{hash[:level]}", style: "padding-left: #{padding}px ")
    end.join.html_safe
  end

  private
    def set_items(items= [], level = 0, z)
      level +=1
      items.each do |i|
        set_data(i, level, z)
      end
    end

    def set_data(item, level, z)
      entity = CompanyEntities.find(item.id)
      z << {level: level, entity: item}
      puts("level = #{level} id = #{entity.id}")
      set_items(entity.descendants, level, z) if entity.descendants.present?
    end
end
