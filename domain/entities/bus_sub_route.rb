# frozen_string_literal: false

require 'dry-struct'
require_relative '../motc_mappers/bus_sub_route_mapper.rb'
require_relative 'stop_of_route.rb'

module TaiGo
  module Entity
    # Domain entity object for git BusRoute
    class BusSubRoute < Dry::Struct
<<<<<<< HEAD
      attribute :id, Types::Strict::String 
=======
      attribute :id, Types::Strict::String
>>>>>>> 5d6f29e31f7ff87d229f33d3ec4de7896bc2fb13
      attribute :route_id, Types::Strict::String
      attribute :name, Types.Instance(TaiGo::MOTC::BusSubRouteMapper::DataMapper::Name)
      attribute :headsign, Types::String.optional
      attribute :direction, Types::Int.optional
      attribute :owned_stop_of_routes, Types::Strict::Array.member(StopOfRoute).optional
    end
  end
end
