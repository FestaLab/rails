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
  class Analyzer::ImageAnalyzer::Vips < Analyzer

    def metadata
      read_image do |image|
        (width, height) = image.autorot.size
        { width: width, height: height }
      end
    end

    private
      def read_image
        download_blob_to_tempfile do |file|
          require "ruby-vips"
          image = Vips::Image.new_from_file(file.path, access: :sequential)

          if valid_image?(image)
            yield image
          else
            logger.info "Skipping image analysis because Vips doesn't support the file"
            {}
          end
        end
      rescue LoadError
        logger.info "Skipping image analysis because the ruby-vips gem isn't installed"
        {}
      rescue Vips::Error => error
        logger.error "Skipping image analysis due to an Vips error: #{error.message}"
        {}
      end

      def valid_image?(image)
        image.avg
        true
      rescue ::Vips::Error
        false
      end
  end
end
