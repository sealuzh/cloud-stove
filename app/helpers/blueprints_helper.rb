module BlueprintsHelper
  def nested_list_from_hash(hash, css_class: nil)
    items = hash.map do |key, value|
      value = if value.is_a?(Hash)
        nested_list_from_hash(value)
      else
        content_tag(:code, value)
      end
      content_tag(:li) do
        content_tag(:span, "#{key}:") + " " + value
      end
    end.join
    content_tag(:ul, items.html_safe, class: css_class)
  end
end
