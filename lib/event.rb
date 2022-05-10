# frozen_string_literal: true

require 'dry-struct'
require_relative 'types'

#
# This is an entity to store Events
#
class Event < Dry::Struct
  transform_keys(&:to_sym)

  attribute :uid, Types::Coercible::String
  attribute :title, Types::Coercible::String
  attribute :time, Types::Strict::Time
  attribute? :description, Types::Coercible::String.optional
  attribute? :location, Types::Coercible::String.optional
  attribute? :url, Types::Coercible::String.optional

  def within?(seconds:, till: nil, from: nil)
    raise(ArgumentError) if till && from

    if from # rubocop:disable Style/MissingElse
      return (from <= time && time <= from + seconds)
    end

    if till # rubocop:disable Style/MissingElse
      return (till >= time && time >= till - seconds)
    end

    raise(ArgumentError)
  end

  def to_dto
    dto = to_hash.transform_keys(&:to_s)
    dto['time'] = dto['time'].to_s
    dto
  end
end
