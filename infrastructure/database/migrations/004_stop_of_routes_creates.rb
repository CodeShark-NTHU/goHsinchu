# frozen_string_literal: false

require 'sequel'

Sequel.migration do
  change do
    create_table(:stop_of_routes) do
      foreign_key :sub_route_uid, :sub_routes
      foreign_key :stop_id, :stops

      Integer		:sequence
      Integer		:boarding

      DateTime    :created_at
      DateTime    :updated_at

      primary_key [:sub_route_uid, :stop_id]
      index [:sub_route_uid, :stop_id]
    end
  end
end
