# Shared concern for models that store JSON arrays in a column and need
# a safe list accessor that always returns an Array.
#
# Usage:
#   class MyModel < ApplicationRecord
#     include ListAttribute
#     list_attribute :options      # → #options_list
#     list_attribute :objectifs    # → #objectifs_list
#   end
module ListAttribute
  extend ActiveSupport::Concern

  class_methods do
    # Declares a list accessor for a JSONB/text array attribute.
    # e.g. list_attribute :objectifs  →  def objectifs_list = Array(objectifs)
    def list_attribute(*attrs)
      attrs.each do |attr|
        define_method(:"#{attr}_list") { Array(public_send(attr)) }
      end
    end
  end
end
