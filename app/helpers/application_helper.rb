module ApplicationHelper
  def render_messages(type)
    return "<div id = 'flash' class = '#{type.to_s}'><div>#{flash[type]}</div></div>".html_safe if flash[type]

    ""
  end
end

