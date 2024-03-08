# frozen_string_literal: true

module Usearch
  module Sort
    extend ActiveSupport::Concern

    class_methods do
      # filters and sortable
      def sort_by_field(all_sorts, default = nil)
        return (default ? order(default) : all) unless all_sorts.present?

        all_sorts = all_sorts.to_s.split("-")
        sort_str = []
        all_sorts.each do |sort|
          sort_key, sort_order = sort&.split(",")
          sort_order = %w[asc ASC DESC desc].include?(sort_order) ? sort_order : "ASC"
          next unless sort_key && has_attribute?(sort_key)

          sort_str << "#{table_name}.#{sort_key} #{sort_order}"
        end

        order(sort_str.join(", "))
      end
    end
  end
end
