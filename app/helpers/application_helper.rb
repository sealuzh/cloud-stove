module ApplicationHelper
  def format_price(price, precision: 2)
    number_to_currency(price, precision: precision)
  end

  def markdown(text)
    @renderer ||= Redcarpet::Render::HTML.new(safe_links_only: true)
    @markdown ||= Redcarpet::Markdown.new(@renderer, autolink: true, tables: true)
    @markdown.render(text || "").html_safe
  end
  
  # Adapted from https://github.com/railscasts/196-nested-model-form-revised/blob/master/questionnaire-after/app/helpers/application_helper.rb
  def link_to_add_fields(name, f, association, klass = association.to_s.camelize.constantize)
    new_object = klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
