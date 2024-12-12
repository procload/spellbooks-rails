module ButtonHelper
  def primary_button(text = nil, **options, &block)
    render_button(:primary, text, **options, &block)
  end

  def secondary_button(text = nil, **options, &block)
    render_button(:secondary, text, **options, &block)
  end

  def negative_button(text = nil, **options, &block)
    render_button(:negative, text, **options, &block)
  end

  def transparent_button(text = nil, **options, &block)
    render_button(:transparent, text, **options, &block)
  end

  private

  def render_button(variant, text = nil, **options, &block)
    options = options.merge(variant: variant)
    
    if block_given?
      render "components/button/button", **options, &block
    else
      render "components/button/button", **options do
        text
      end
    end
  end
end 