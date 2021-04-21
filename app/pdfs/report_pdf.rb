# Load dependencies.
require 'prawn/measurement_extensions'

# Report PDF.
class ReportPdf < Prawn::Document

  # Constructor.
  def initialize(dmr)

    # Suppress character warning.
    Prawn::Font::AFM.hide_m17n_warning = true

    # Store record.
    @dmr = dmr

    # Initialize Prawn document.
    super(top_margin: 0.in,
          bottom_margin: 0.in,
          left_margin: 0.in,
          right_margin: 0.in,
          page_layout: :portrait)
    
    # Load fonts.
    self.load_fonts
  
    # Draw DMR.
    self.draw_dmr

  end

  # Loads fonts.
  def load_fonts
    self.load_single_font('Gotham Condensed')
  end

  # Loads single font using Prawn's font_families.update method.
  def load_single_font(name)
    
    # Determine path to font file.
    font_file_name = name.gsub(/\s+/, "")
    path = Rails.root.join('lib', 'assets', 'fonts', "#{font_file_name}.ttf")
    return unless File.file?(path)

    # Determine variants.
    italics_path = Rails.root.join('lib', 'assets', 'fonts', "#{font_file_name}-Italic.ttf")
    bold_path = Rails.root.join('lib', 'assets', 'fonts', "#{font_file_name}-Bold.ttf")
    bold_italics_path = Rails.root.join('lib', 'assets', 'fonts', "#{font_file_name}-BoldItalic.ttf")

    # Build hash of variants.
    font_hash = { normal: path }
    font_hash[:italic] = italics_path if File.file?(italics_path)
    font_hash[:bold] = bold_path if File.file?(bold_path)
    font_hash[:bold_italic] = bold_italics_path if File.file?(bold_italics_path)

    # Add font.
    self.font_families.update(name => font_hash)

  end

  # Renderer. Adds letterhead graphics to all pages.
  def render

    # Load graphics.
    path = Rails.root.join('lib', 'assets', 'letterhead', 'letterhead.png')
    
    # Draw graphics on each page.
    self.repeat(:all) do
      self.image(path, at: [0.25.in, 10.75.in], width: 8.in, height: 1.25.in)
    end

    # Call parent render.
    super

  end

  # Draws rectangle.
  def rect(x, y, width, height, options = {})
    line_color = options.fetch(:line_color, "000000")
    fill_color = options.fetch(:fill_color, nil)
    line_width = options.fetch(:line_width, nil)
    unless fill_color.blank?
      self.fill_color(fill_color)
      self.fill_rectangle([x.in, y.in], width.in, height.in)
    end
    unless line_color.blank?
      self.stroke_color(line_color)
      self.line_width = line_width.in if line_width
      self.stroke_rectangle([x.in, y.in], width.in, height.in)
    end
  end

  # Draws text box.
  def txtb(text, x, y, width, height, options = {})

    # Exit if no text passed.
    return if text.blank? && !options.fetch(:print_blank, false)

    # Convert passed text to string.
    text = text.to_s

    # Load passed options or fall back to defaults.
    fill_color = options.fetch(:fill_color, nil)
    line_color = options.fetch(:line_color, nil)
    line_width = options.fetch(:line_width, nil)
    font_family = options.fetch(:font, 'Helvetica')
    font_style = options.fetch(:style, :normal)
    font_size = options.fetch(:size, 10)
    font_color = options.fetch(:color, "000000")
    h_align = options.fetch(:h_align, :center)
    v_align = options.fetch(:v_align, :center)
    h_pad = options.fetch(:h_pad, 0)
    v_pad = options.fetch(:v_pad, 0)

    # If stroke/fill options passed, draw rectangle.
    if fill_color || line_color
      self.rect(x, y, width, height, fill_color: fill_color, line_color: line_color, line_width: line_width)
    end

    # Set font.
    self.font(font_family, style: font_style)
    self.font_size(font_size)
    self.fill_color(font_color)

    # Draw text box.
    self.text_box(text,
                  at: [(x + h_pad).in, (y - v_pad).in],
                  width: (width - 2 * h_pad).in,
                  height: (height - 2 * v_pad).in,
                  align: h_align,
                  valign: v_align,
                  inline_format: true,
                  overflow: :shrink_to_fit)

  end

  # Draws DMR data.
  def draw_dmr

    # Draw body.
    y = 6.85 - 0.25 * (@dmr.part_name.length + @dmr.purchase_order.length)
    self.font('Helvetica', style: :normal)
    self.font_size(10)
    self.bounding_box([0.35.in, (y - 0.1).in], width: 7.8.in, height: (y - 0.7).in) do
      self.text(@dmr.body, inline_format: true)
    end
    page_count_so_far = self.page_count

    # Draw boxes around body and header information on each page.
    (1..page_count_so_far).each do |p|

      # Draw page number.
      self.go_to_page(p)

      # Draw name and title.
      sent_by = @dmr.user.name
      unless @dmr.user.title.blank?
        sent_by += ", #{@dmr.user.title}"
      end
      self.txtb("Sent By: <strong>#{sent_by}</strong>", 0.25, 0.5, 8, 0.25, size: 10, h_align: :right, v_align: :bottom)

      # Draw box around body.
      y = 6.85 - 0.25 * (@dmr.part_name.length + @dmr.purchase_order.length)
      self.rect(0.25, y, 8, y - 0.5)

      # Print disposition information.
      y = 8.6
      self.txtb("Disposition of Parts", 4.375, y, 3.875, 0.25, size: 10, fill_color: "dddddd", line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25
      self.txtb(self.disposition_label(@dmr.disposition).upcase, 4.375, y, 3.875, 0.5, size: 10, style: :bold, line_color: "000000", h_align: :center)
      y -= 0.75
      self.txtb("Defect Discovered", 4.375, y, 3.875, 0.25, size: 10, fill_color: "dddddd", line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25
      self.txtb(self.discovery_label(@dmr.discovery_stage).upcase, 4.375, y, 3.875, 0.5, size: 10, style: :bold, line_color: "000000", h_align: :center)
      
      # Print order information.
      y = 8.6
      self.txtb("Order Information", 0.25, y, 3.875, 0.25, size: 10, fill_color: "dddddd", line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25
      self.txtb("Varland Order #", 0.25, y, 1.25, 0.25, size: 10, line_color: "000000", h_align: :left, h_pad: 0.1)
      self.txtb(@dmr.shop_order, 1.5, y, 2.625, 0.25, size: 10, style: :bold, line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25
      self.txtb("Part #", 0.25, y, 1.25, 0.25, size: 10, line_color: "000000", h_align: :left, h_pad: 0.1)
      self.txtb(@dmr.part, 1.5, y, 2.625, 0.25, size: 10, style: :bold, line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25
      self.txtb("Part Name" + ("\n" * @dmr.part_name.length), 0.25, y, 1.25, 0.25 * @dmr.part_name.length, size: 10, line_color: "000000", h_align: :left, h_pad: 0.1)
      self.txtb(@dmr.part_name.join("\n"), 1.5, y, 2.625, 0.25 * @dmr.part_name.length, size: 10, style: :bold, line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25 * @dmr.part_name.length
      self.txtb("Purchase Order" + ("\n" * @dmr.purchase_order.length), 0.25, y, 1.25, 0.25 * @dmr.purchase_order.length, size: 10, line_color: "000000", h_align: :left, h_pad: 0.1)
      self.txtb(@dmr.purchase_order.join("\n"), 1.5, y, 2.625, 0.25 * @dmr.purchase_order.length, size: 10, style: :bold, line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25 * @dmr.purchase_order.length
      self.txtb("Pieces", 0.25, y, 1.25, 0.25, size: 10, line_color: "000000", h_align: :left, h_pad: 0.1)
      self.txtb(self.helpers.number_with_delimiter(@dmr.pieces), 1.5, y, 2.625, 0.25, size: 10, style: :bold, line_color: "000000", h_align: :left, h_pad: 0.1)
      y -= 0.25
      self.txtb("Pounds", 0.25, y, 1.25, 0.25, size: 10, line_color: "000000", h_align: :left, h_pad: 0.1)
      self.txtb(self.helpers.number_with_precision(@dmr.pounds, precision: 2, strip_insignificant_zeros: true, delimiter: ","), 1.5, y, 2.625, 0.25, size: 10, style: :bold, line_color: "000000", h_align: :left, h_pad: 0.1)

      # Draw header for details.
      y -= 0.5
      self.txtb("Details", 0.25, y, 8, 0.25, size: 10, fill_color: "dddddd", line_color: "000000", h_align: :left, h_pad: 0.1)
      self.txtb("(Page #{p} of #{page_count_so_far})", 0.25, y, 8, 0.25, size: 8, h_align: :right, h_pad: 0.1) if page_count_so_far > 1

    end

    # Add attachments.
    max_image_width = 7.5
    max_image_height = 7.3
    @dmr.attachments.each do |attachment|
      next if attachment.file.content_type == 'application/pdf'
      this_image_height = max_image_height
      self.start_new_page
      self.txtb(attachment.name, 0.5, 8.75, 7.5, 0.25, size: 14, h_align: :center)
      if attachment.description.blank?
        this_image_height += 0.6
      else
        self.txtb(attachment.description, 0.5, 8.4, 7.5, 0.5, style: :italic, size: 10, h_align: :center, v_align: :top)
      end
      image = self.get_image(attachment.file, max_image_width, this_image_height)
      self.bounding_box([(0.5 + ((max_image_width - image[:width]) / 2.0)).in, ((this_image_height + 0.5) - ((this_image_height - image[:height]) / 2.0)).in], width: image[:width].in, height: image[:height].in) do
        self.image(image[:path], fit: [image[:width].in, image[:height].in])
      end
    end

    # Draw DMR number and date.
    self.repeat(:all) do
      self.txtb("DEFECTIVE MATERIAL REPORT: #{@dmr.dmr_number}", 0.25, 9.5, 8, 0.4, style: :bold, size: 18, h_align: :center, v_align: :bottom)
      self.txtb("Date: #{@dmr.sent_on.strftime("%m/%d/%Y")}", 0.25, 9.1, 8, 0.25, style: :bold, size: 10, h_align: :center, v_align: :top)
    end

  end

  # Reads image data and auto-orients image if necessary.
  def get_image(file, max_width, max_height)
    max_width_pixels = max_width * 300
    max_height_pixels = max_height * 300
    magick = MiniMagick::Image.read(file.download)
    magick.auto_orient
    magick.resize("#{max_width_pixels}x#{max_height_pixels}") if magick.height > max_height_pixels || magick.width > max_width_pixels
    temp_path = "#{Dir.tmpdir}/#{SecureRandom.alphanumeric(50)}"
    magick.write(temp_path)
    return { path: temp_path, height: magick.height / 300.0, width: magick.width / 300.0 }
  end

  # Gets label for disposition.
  def disposition_label(disposition)
    case disposition
    when "unprocessed"
      "Unprocessed"
    when "partial"
      "Partially Processed"
    when "complete"
      "Completely Processed"
    end
  end

  # Gets label for discovery stage.
  def discovery_label(stage)
    return "#{stage.humanize} Processing"
  end

  # Protected methods.
  protected
  
    # Reference Rails helpers.
    def helpers
      ApplicationController.helpers
    end

end