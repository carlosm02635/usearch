# frozen_string_literal: true

require_relative "usearch/version"
require_relative "usearch/models/concerns/search_all_scope"
require_relative "usearch/models/concerns/sort"

module Usearch
  class Error < StandardError; end
end
