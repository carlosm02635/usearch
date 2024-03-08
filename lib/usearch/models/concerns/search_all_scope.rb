# frozen_string_literal: true

module Usearch
  module SearchAllScope
    extend ActiveSupport::Concern

    included do
      class_attribute :_search_all_scope_fields, instance_writer: false, default: []

      scope :search_all, lambda { |query:|
                           return nil if query.blank?

                           # if query is something like "query*% text words"
                           terms = query.downcase.split(/\s+/)
                           # terms is ["query*%", "text", "words"] because we made the split by " "

                           # replace "*" with "%" for wildcard searches,
                           # append '%', remove duplicate '%'s
                           terms.map! { "%#{I18n.transliterate(_1).tr("*", "%")}%".gsub(/%+/, "%") }
                           # after this map! terms is ["%query%", "%text%", "%words%"]
                           # note that first it was "query*%" then "%query*%%", after .tr (that changes * to %)
                           # was "%query%%%", and finally after .gsub (that removes duplicate %) is "%query%"

                           # search_all_scope_fields is an array of field names as symbols, smtg like [:name, :another_field, ...]
                           # for joined table attrs we receive an array like [[:table_name, :joined_table_attr]] so we access to the second element
                           conditions = search_all_scope_fields.map do
                             "unaccent(" \
                             "LOWER(" \
                             "TEXT(" \
                             "#{_1.is_a?(Array) ? "#{_1[0].to_s.pluralize}.#{_1[1]}" : "#{table_name}.#{_1}"}" \
                             ")" \
                             ")" \
                             ") LIKE ?"
                           end
                           # conditions is an array with this structure:
                           # [ "(unaccent(LOWER(TEXT(name))) LIKE ?", "(unaccent(LOWER(TEXT(another_field))) LIKE ?", ... ]

                           return if conditions.empty?

                           # if we have smtg like [:field, [:table_name, :joined_field], [:table_name_two, :joined_field]]
                           # after this we get [:table_name, :table_name_two]
                           tables_to_join = search_all_scope_fields.select { _1.is_a?(Array) }.map { _1[0] }

                           response = self
                           response = response.left_joins(*tables_to_join) if tables_to_join.present?
                           response.where(
                             terms.map { "(#{conditions.join(" OR ")})" }.join(" AND "),
                             # first we do a map to terms array in order to generate the OR conditions, so we end up with:
                             # [
                             #   "(unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(another_field))) LIKE ?)",
                             #   "(unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(another_field))) LIKE ?)",
                             #   "(unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(another_field))) LIKE ?)",
                             # ]
                             # then we do a join with using the AND word, so it becomes a string like this:
                             # "(unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(description))) LIKE ?) AND
                             #  (unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(description))) LIKE ?) AND
                             #  (unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(description))) LIKE ?)"
                             *terms.map { [_1] * conditions.size }.flatten
                             # we do a map for the terms ["%query%", "%text%", "%words%"], after that we have:
                             # [["%query%", "%query%"], ["%text%", "%text%"], ["%words%", "%words%"]]
                             # then we do a flatten to this, and it becomes:
                             # ["%query%", "%query%", "%text%", "%text%", "%words%", "%words%"]
                           )
                           # so at the end the "where" clause looks like:
                           # where(
                           #  "(unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(description))) LIKE ?)
                           #   AND (unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(description))) LIKE ?)
                           #   AND (unaccent(LOWER(TEXT(name))) LIKE ? OR unaccent(LOWER(TEXT(description))) LIKE ?)",
                           #  "%query%", "%query%", "%text%", "%text%", "%words%", "%words%"
                           # )
                         }
    end

    class_methods do
      def search_all_scope_fields(*search_all_scope_fields)
        _search_all_scope_fields.concat(search_all_scope_fields)
      end
    end
  end
end
