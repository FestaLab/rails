# frozen_string_literal: true

module ActiveStorage
  # Extracts width and height in pixels from an image blob.
  #
  # If the image contains EXIF data indicating its angle is 90 or 270 degrees, its width and height are swapped for convenience.
  #
  # Example:
  #
  #   ActiveStorage::Analyzer::ImageAnalyzer.new(blob).metadata
  #   # => { width: 4104, height: 2736 }
  #
  # This analyzer relies on the third-party {MiniMagick}[https://github.com/minimagick/minimagick] gem. MiniMagick requires
  # the {ImageMagick}[http://www.imagemagick.org] system library.
  class Analyzer::ImageAnalyzer < Analyzer
    def self.accept?(blob)
      blob.image?
    end

    def metadata
      if ActiveStorage.variant_processor == :vips
        puts "============================== Vips selected"
        Analyzer::ImageAnalyzer::Vips.new(@blob).metadata
      else
        puts "============================== Vips selected"
        Analyzer::ImageAnalyzer::ImageMagick.new(@blob).metadata
      end
    end
  end
end
