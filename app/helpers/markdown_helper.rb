module MarkdownHelper
  def markdown(text)
    return '' if text.blank?
    
    # Remove any leading markdown language indicators
    text = text.sub(/\A```\w+\n/, '')
    text = text.sub(/\n```\z/, '')
    
    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: false,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end