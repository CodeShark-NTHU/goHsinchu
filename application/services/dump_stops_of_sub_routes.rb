# frozen_string_literal: true

require 'dry/transaction'

module TaiGo
  # Transaction to combine Google map direction with MOTC
  class DumpStopsOfSubRoutes
    include Dry::Transaction

    step :extract_bus_route_name_from_bus_direcrtion
    step :transform_route_name_for_motc
    step :get_sub_routes_for_each_route
    step :remove_the_wrong_sub_routes
    step :dump_stops_of_sub_routes_into_bus_direction

    def extract_bus_route_name_from_bus_direcrtion(input)
      index_bus_sub_route_name = []
      result = []
      input[:gm_directions].each_with_index do |direction, index1|
        direction.bus_steps.each_with_index do |bus_step, index2|
          index_bus_sub_route_name << [index1, index2, bus_step.bus_sub_route_name, bus_step.bus_departure_stop_name, bus_step.bus_arrival_stop_name, bus_step.bus_num_stops]
        end
      end
      result << input[:gm_directions]
      result << index_bus_sub_route_name
      Right(result: result)
    end

    def transform_route_name_for_motc(input)
      result = []
      index_bus_sub_route_name = input[:result][1]
      index_bus_sub_route_name.map do |pair|
        name_zh = pair[2]
        pair[2] = motc_name(name_zh)
      end
      result << input[:result][0]
      result << index_bus_sub_route_name
      Right(result: result)
    end

    def get_sub_routes_for_each_route(input)
      result = []
      tmp = []
      direction_set = input[:result][0]
      index_bus_sub_route_name = input[:result][1]
      index_bus_sub_route_name.each_with_index do |pair, index|
        name_zh = pair[2]
        route = Repository::For[Entity::BusRoute].find_name_ch(name_zh)
        pair[2] = get_sub_routes(route)
        unless route.nil?
          tmp << index_bus_sub_route_name[index]
        end
      end
      result << direction_set
      result << tmp
      Right(result: result)
    end

    def remove_the_wrong_sub_routes(input)
      index_bus_sub_routes = input[:result][1]
      result = []
      index_bus_sub_routes.map do |pair|
        subroutes = pair[2]
        #puts subroutes.size
        departure_stop_name = motc_stop_name(pair[3])
        arrival_stop_name = motc_stop_name(pair[4])
        bus_num_stops = pair[5]
        subroutes.each do |sub|
          array_of_sor = get_array_of_sor(sub.id)
          departure = sor_motc_arr(array_of_sor, departure_stop_name)
          arrival = sor_motc_arr(array_of_sor, arrival_stop_name)
          right_sub_route = check_stop_num(departure, arrival, bus_num_stops)
          pair[2] = [] # clear
          # puts right_sub_route
          next unless right_sub_route
          ch_name = ch_name_of_sub_route(array_of_sor[0])
          # puts ch_name
          pair[2] << Entity::StopsOfSubRoute.new(sub_route_name_ch: ch_name,
                                                 stops_of_sub_route: array_of_sor)
        end
      end
      result << input[:result][0]
      result << index_bus_sub_routes
      Right(result: result)
    end

    def dump_stops_of_sub_routes_into_bus_direction(input)
      gm_directions = input[:result][0]
      index_bus_sub_routes = input[:result][1]
      result = combine(gm_directions, index_bus_sub_routes)
      Right(Result.new(:ok, result))
    end

    private

    def motc_name(name_zh)
      name_zh.insert 1, '線' if name_zh[0] == '藍' && name_zh[2] == '區'
      name_zh.concat('號') if name_zh[0..1] == '世博'
      name_zh = '藍線1區' if name_zh == 'BL1 Qu'
      name_zh = '藍15區' if name_zh == 'BL Area 15'
      name_zh = '世博1號' if name_zh == 'Shi Bo 1'
      name_zh = '世博3號' if name_zh == 'Shi Bo 3'
      name_zh = '世博5號' if name_zh == 'Shi Bo 5'
      name_zh = '藍線' if name_zh == 'Blue Line'
      name_zh = '綠線' if name_zh == 'Green Line'
      name_zh
    end

    def get_sub_routes(route)
      result = []
      unless route.nil?
        id = route.id
        subs = Repository::For[Entity::BusSubRoute].find_sub_route_by_id(id)
        subs.each do |s|
          result << s
        end
      end
      result
    end

    def get_array_of_sor(sr_id)
      Repository::For[Entity::StopOfRoute].find_all_stop_of_a_sub_route(sr_id)
    end

    def motc_stop_name(name)
      name.split('[')[0]
    end

    def sor_motc_arr(stops_of_sub_route, stop_name)
      stop_arr = []
      stops_of_sub_route.each do |sor|
        stop_arr << sor.stop_sequence if sor.stop.name.chinese == stop_name
      end
      stop_arr
    end

    def check_stop_num(departure_arr, arrival_arr, anwser)
      right_sub_route = false
      departure_arr.each do |departure|
        arrival_arr.each do |arrival|
          next unless (arrival - departure) == anwser
          right_sub_route = true
          break
        end
      end
      # right_sub_route
      true
    end

    def ch_name_of_sub_route(sor)
      sr_name = sor.sub_route.name.chinese
      # sr_headsign = sor.sub_route.headsign
      sr_name
    end

    def combine(gm_directions, index_bus_sub_routes)
      puts index_bus_sub_routes
      result = []
      [index_bus_sub_routes[0]].each do |item|
        item[2].map do |ssor|
          gm_directions[item[0]].bus_steps[item[1]].sub_routes << ssor
        end
        result << gm_directions[item[0]]
      end
      result
    end
  end
end
