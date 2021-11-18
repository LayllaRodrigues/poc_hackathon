require 'rtesseract'
require 'open3'
require 'mini_magick'

src_path = 'odo_1.jpeg'

resp = (8..20).step(2).each.inject([]) do |collection, x|
  image = MiniMagick::Image.open(src_path)
  image.colorspace 'Gray'
  # image.negate
  # image.threshold("00#{x}%")
  # image.negate

  tmp_path = "paineledit#{x}.png"
  image.write tmp_path

  (0..13).each do |psm_opt|
    text, _, _ =
      Open3.capture3("tesseract #{tmp_path} stdout -c tessedit_char_whitelist=0123456789 --psm #{psm_opt}")
    puts "threshold #{x}% with C++ --psm #{psm_opt}: #{text.strip}"
  end

  odometer_img = RTesseract.new(tmp_path, config_file: :digits)

  collection << odometer_img.to_box.first[:word] if odometer_img.to_box.any?

  collection
end

puts resp.inspect
