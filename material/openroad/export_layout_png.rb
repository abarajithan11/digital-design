gds = ENV.fetch("GDS_FILE")
lyp = ENV.fetch("LYP_FILE")
png = ENV.fetch("PNG_FILE")
size = Integer(ENV.fetch("PNG_SIZE", "4096"))

raise "GDS file not found: #{gds}" unless File.file?(gds)
raise "Layer properties file not found: #{lyp}" unless File.file?(lyp)

view = RBA::LayoutView.new
view.load_layout(gds, 0)
view.load_layer_props(lyp)
view.max_hier
view.zoom_fit
view.save_image(png, size, size)

puts "Saved layout PNG: #{png} (#{size}x#{size})"
RBA::Application.instance.exit(0)
