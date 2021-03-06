require 'sprockets/encoding_utils'

module Sprockets
  module Mime
    # Pubic: Mapping of MIME type Strings to properties Hash.
    #
    # key   - MIME Type String
    # value - Hash
    #   extensions - Array of extnames
    #   charset    - Default Encoding or function to detect encoding
    #
    # Returns Hash.
    attr_reader :mime_types

    attr_reader :mime_exts

    # Register a new mime type.
    def register_mime_type(mime_type, options = {})
      # Legacy extension argument, will be removed from 4.x
      if options.is_a?(String)
        options = { extensions: [options] }
      end

      extnames = Array(options[:extensions]).map { |extname|
        Sprockets::Utils.normalize_extension(extname)
      }

      charset = options[:charset]
      charset ||= EncodingUtils::DETECT if mime_type.start_with?('text/')

      extnames.each do |extname|
        @mime_exts[extname] = mime_type
      end

      @mime_types[mime_type] = {}
      @mime_types[mime_type][:extensions] = extnames
      @mime_types[mime_type][:charset] = charset if charset
      @mime_types[mime_type]
    end

    def mime_type_for_extname(extname)
      @mime_exts.fetch(extname) { 'application/octet-stream' }
    end

    # Public: Test mime type against mime range.
    #
    #    match_mime_type?('text/html', 'text/*') => true
    #    match_mime_type?('text/plain', '*') => true
    #    match_mime_type?('text/html', 'application/json') => false
    #
    # Returns true if the given value is a mime match for the given mime match
    # specification, false otherwise.
    def match_mime_type?(value, matcher)
      v1, v2 = value.split('/', 2)
      m1, m2 = matcher.split('/', 2)
      (m1 == '*' || v1 == m1) && (m2.nil? || m2 == '*' || m2 == v2)
    end
  end
end
