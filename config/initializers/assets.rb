# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Exclude PDF styles from default precompilation
Rails.application.config.assets.precompile.delete('pdf.css')

# Only precompile PDF styles when explicitly requested by wicked_pdf
Rails.application.config.assets.precompile += ['pdf.css']
