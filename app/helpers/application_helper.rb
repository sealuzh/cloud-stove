module ApplicationHelper
  def page_title
    if content_for(:title)
      yield(:title)
    else
      page_scope = [ controller_path.tr('/', '.'), action_name ].join('.')
      [ 
        I18n.t('.title', scope: page_scope, default: ''), 
        I18n.t('app_name')
      ].reject(&:blank?).join(" • ")
    end
  end
  
  def nav_link(title, url)
    classes = [ 'nav-item', 'nav-link' ]
    classes << 'active' if request.env['PATH_INFO'].start_with?(url)
    link_to(title, url, class: classes.join(' '))
  end
  
  def format_price(price, precision: 2)
    number_to_currency(price, precision: precision)
  end

  # Render Markdown for body copy.
  def markdown(text)
    # Body copy headings should never be h1
    text.gsub!(/^#/, '##') if text
    @renderer ||= Redcarpet::Render::HTML.new(safe_links_only: true)
    @markdown ||= Redcarpet::Markdown.new(@renderer, autolink: true, tables: true)
    @markdown.render(text || "").html_safe
  end
  
  # Adapted from https://github.com/railscasts/196-nested-model-form-revised/blob/master/questionnaire-after/app/helpers/application_helper.rb
  def link_to_add_fields(name, f, association, klass = association.to_s.camelize.constantize)
    id = Time.now.to_i
    fields = sub_form(f, association, klass, id)
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def sub_form(f, association, klass = association.to_s.camelize.constantize, id = Time.now.to_i)
    fields = f.fields_for(association, klass.new, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
  end


end
