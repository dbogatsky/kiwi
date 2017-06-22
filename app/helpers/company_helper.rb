module CompanyHelper

  def nested_entities(entities)
    entities = entities.as_json
    generate_entities_table_recur(nil, entities, 1).html_safe
  end

  private

    def generate_entities_table_recur(parent_id, entities, level)
      html = ''
      entities.each do |entity|
        entity_parent_id = entity["parent"].as_json.present? ? entity["parent"].as_json["id"] : nil
        if entity_parent_id == parent_id
          padding = level * 10
          html += content_tag(:ul, render('company/entity', entity: entity),
                    class: "table_head table_content level_#{level}", style: "padding-left: #{padding}px ")
          html += generate_entities_table_recur(entity["id"], entities, level+1)
        end
      end
      html
    end

end
