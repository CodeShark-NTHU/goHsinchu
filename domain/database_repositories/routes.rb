# frozen_string_literal: true

module TaiGo
  module Repository
    # Repository for Routes
    class Routes

      def self.find(entity)
        find_id(entity.route_uid)
      end

      def self.find_id(id)
        db_record = Database::RouteOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_name_ch(name_zh)
        db_record = Database::RouteOrm.first(name_zh: name_zh)
        puts db_record
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        find_id(entity.route_uid) || create_from(entity)
      end

      def self.create_from(entity)
        # raise 'Route already exists in db' if find(entity)

        Database::RouteOrm.unrestrict_primary_key
        db_route = Database::RouteOrm.create(
          id: entity.route_uid,
          name_en: entity.route_name.english,
          name_zh: entity.route_name.chinese,
          dep_en: entity.depart_name.english,
          dep_zh: entity.depart_name.chinese,
          dest_en: entity.destination_name.english,
          dest_zh: entity.destination_name.chinese,
          auth_id: entity.authority_id
        )

        # insert to subroute db
        # entity.sub_routes.each do |sub_route|
          # stored_sub_route = SubRoutes.find_or_create(sub_route,
                                                      # entity.route_uid)
          # sroute = Database::SubRouteOrm.first(id: stored_sub_route.id)
          # db_route.add_sub_routes(sroute)
        # end

        rebuild_entity(db_route)
      end

      # db -> entity
      def self.rebuild_entity(db_record)
        return nil unless db_record

        # sroutes = db_record.sub_routes.map do |db_sroutes|
          # SubRoutes.rebuild_entity(db_sroutes)
        # end

        Entity::BusRoute.new(
          route_uid: db_record.id,
          route_name: TaiGo::MOTC::BusRouteMapper::DataMapper::Name.new(db_record.name_en,db_record.name_zh),
          depart_name: TaiGo::MOTC::BusRouteMapper::DataMapper::Name.new(db_record.dep_en,db_record.dep_zh),
          destination_name: TaiGo::MOTC::BusRouteMapper::DataMapper::Name.new(db_record.dest_en,db_record.dest_zh),
          authority_id: db_record.auth_id
          # sub_routes: sroutes
        )
      end

      # def self.find(entity)
      #   find_route_uid(entity.route_uid)
      # end

      # return all rotues in db to entity
      # def all
      #   Database::RouteOrm.all.map |db_route|
      #   rebuild_entity(db_route)
      # end
    end
  end
end