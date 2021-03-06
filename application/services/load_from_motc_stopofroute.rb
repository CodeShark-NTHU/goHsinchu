# frozen_string_literal: true

require 'dry/transaction'

module TaiGo
  # Transaction to load stopofroute from Motc and save to database
  class LoadFromMotcStopOfRoute
    include Dry::Transaction

    step :get_stopofroute_from_motc
    step :filter_the_stopofroute_not_in_db
    step :store_stopofroute_in_repository

    def get_stopofroute_from_motc(input)
      stopofroutes = TaiGo::MOTC::StopOfRouteMapper.new(input[:config])
                                                   .load(input[:city_name])
      Right(stopofroutes: stopofroutes)
    rescue StandardError
      Left(Result.new(:not_found, 'stopofroutes not found'))
    end

    def filter_the_stopofroute_not_in_db(input)
      stopofroute_set = []
      input[:stopofroutes].map do |sor|
        stopofroute_set << sor if Repository::For[sor.class]
                                  .find_stop_of_route(sor.sub_route_id,
                                                      sor.stop_id,
                                                      sor.stop_sequence).nil?
      end
      if stopofroute_set.empty?
        Left(Result.new(:conflict, 'all of stopofroute already loaded'))
      else
        Right(unstored_stopofroute: stopofroute_set)
      end
    end

    def store_stopofroute_in_repository(input)
      stored_stopofroute = []
      input[:unstored_stopofroute].map do |sor|
        stored_stopofroute << Repository::For[sor.class].create_from(sor)
      end
      Right(Result.new(:created, stored_stopofroute))
    rescue StandardError => e
      puts e.to_s
      Left(Result.new(:internal_error, 'Could not store remote repository'))
    end
  end
end
