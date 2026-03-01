# Shared concern for models that have a `statut` column.
# Including model MUST define a STATUTS constant.
#
# Usage:
#   class MyModel < ApplicationRecord
#     include Statutable
#     STATUTS = %w[brouillon publie].freeze
#   end
module Statutable
  extend ActiveSupport::Concern

  included do
    validates :statut, inclusion: { in: -> (r) { r.class::STATUTS } }, allow_blank: true
  end

  # Returns all statuts defined for this model class
  def statuts_disponibles
    self.class::STATUTS
  end

  # Returns true if the model is in the given statut
  def en_statut?(name)
    statut == name.to_s
  end
end
