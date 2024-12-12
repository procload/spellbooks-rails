module FormHelper
  def text_input(name, **options)
    render "components/form/text_input/text_input", name: name, **options
  end
end 