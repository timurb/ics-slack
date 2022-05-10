# frozen_string_literal: true

#
# This is an entity to store Events
#

require 'dry-types'
require 'dry-struct'

module Types
  include Dry.Types
end

class Event < Dry::Struct
  transform_keys(&:to_sym)

  attribute :uid, Types::Coercible::String
  attribute :title, Types::Coercible::String
  attribute :time, Types::Strict::Time
  attribute? :description, Types::Coercible::String.optional
  attribute? :location, Types::Coercible::String.optional
  attribute? :url, Types::Coercible::String.optional

  def to_dto
    dto = self.to_hash.transform_keys {|k| k.to_s}
    dto['time'] = dto['time'].to_s
    dto
  end
end
