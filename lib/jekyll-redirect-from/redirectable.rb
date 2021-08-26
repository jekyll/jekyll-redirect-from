# frozen_string_literal: true

module JekyllRedirectFrom
  # Module which can be mixed in to documents (and pages) to provide
  # redirect_to and redirect_from helpers
  module Redirectable
    # Returns a string representing the relative path or URL
    # to which the document should be redirected
    def redirect_to
      meta_data = to_liquid["redirect_to"]
      meta_data.is_a?(Array) ? meta_data.compact.first : meta_data
    end

    # Returns an array representing the relative paths to other
    # documents which should be redirected to this document
    def redirect_from
      meta_data = to_liquid["redirect_from"]
      meta_data.is_a?(Array) ? meta_data.compact : [meta_data].compact
    end
  end
end
