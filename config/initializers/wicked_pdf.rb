# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.configure do |config|
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  # config.exe_path = '/usr/local/bin/wkhtmltopdf'

  # Enable local file access for wkhtmltopdf 0.12.6+
  config.enable_local_file_access = true

  if Rails.env.development?
    # In development, use the asset pipeline
    assets_path = Rails.root.join('app', 'assets')
    config.default_protocol = 'https'
  else
    # In production, use precompiled assets
    assets_path = Rails.root.join('public', 'assets')
  end

  # Layout file to be used for all PDFs
  # config.layout = 'pdf.html'

  # Default options for all PDFs
  config.default_options = {
    encoding: 'UTF-8',
    page_size: 'Letter',
    margin: {
      top: 20,
      bottom: 20,
      left: 20,
      right: 20
    },
    dpi: 300,
    print_media_type: true,
    no_background: false
  }
end
