module Thinkspace; module PubSub; module AuthorizeHelpers

  extend ::ActiveSupport::Concern

  included do

    def get_auth; params[:auth] || Hash.new; end

    def team?;           authable.is_a?(team_class); end
    def has_authable?;   get_auth[:authable_type].present? || get_auth[:authable_id].present?; end

    def team_class;  Thinkspace::Team::Team; end
    def phase_class; Thinkspace::Casespace::Phase; end

    # ###
    # ### Validate Rooms.
    # ###

    def validate_rooms(rooms, room_type=nil, arecord=authable, orecord=ownerable)
      can?(:update, arecord) ? validate_start_with_rooms(rooms, room_type, arecord, orecord) : validate_reader_rooms(rooms, room_type, arecord, orecord)
    end

    def validate_start_with_rooms(rooms, room_type, arecord=authable, orecord=ownerable)
      assignment      = arecord.is_a?(phase_class) ? arecord.thinkspace_casespace_assignment : arecord
      assignment_room = pubsub.room_for(assignment)
      return if invalid_start_with_rooms(rooms, assignment_room).blank?  # often will be the assignment room so check first
      phases      = assignment.thinkspace_casespace_phases.accessible_by(current_ability)
      start_withs = phases.map {|p| pubsub.room_for(p)}
      access_denied "Unauthorized updater server event rooms as no valid start-with rooms." if start_withs.blank?
      invalid_rooms = invalid_start_with_rooms(rooms, start_withs)
      access_denied "Unauthorized updater server event rooms #{invalid_rooms}." if invalid_rooms.present?
    end

    def invalid_start_with_rooms(rooms, start_withs)
      invalid_rooms = Array.new
      Array.wrap(rooms).each do |room|
        valid = false
        Array.wrap(start_withs).each do |sw|
          valid = true if room.start_with?(sw)
          break if valid
        end
        invalid_rooms.push(room) unless valid
      end
      invalid_rooms
    end

    def validate_reader_rooms(rooms, room_type, arecord=authable, orecord=ownerable)
      assignment = arecord.is_a?(phase_class) ? arecord.thinkspace_casespace_assignment : arecord
      if room_type == 'tracker'
        assignment_room = pubsub.room_for(assignment)
        return if reader_rooms_valid?(assignment_room, rooms)
      end
      valid_rooms  = get_valid_reader_room_set(assignment, current_user)
      valid_rooms += get_valid_reader_rooms(arecord, orecord)
      reader_rooms_valid?(valid_rooms, rooms)
    end

    def reader_rooms_valid?(valid_rooms, rooms)
      Array.wrap(rooms).each do |room|
        access_denied "Unauthorized server event room #{room.inspect}." unless valid_rooms.include?(room)
      end
    end

    def get_valid_reader_rooms(arecord=authable, orecord=ownerable)
      valid_rooms = get_valid_reader_room_set(arecord, orecord)
      if arecord.is_a?(phase_class)
        assignment   = arecord.thinkspace_casespace_assignment
        valid_rooms += get_valid_reader_room_set(assignment, orecord)
      end
      valid_rooms
    end

    def get_valid_reader_room_set(arecord, orecord)
      access_denied "A valid room set required an authable."   if arecord.blank?
      access_denied "A valid room set required an ownerable."  if orecord.blank?
      access_denied "Not authorized to access rooms for #{arecrod.inspect}."  unless can?(:read, arecord)
      access_denied "Not authorized to access rooms for #{orecord.inspect}."  unless can?(:read, orecord)
      valid_rooms = [
        pubsub.room_with_ownerable(arecord, orecord),
        pubsub.room_with_ownerable(arecord, orecord, :server_event),
      ]
      valid_rooms
    end

    # ###
    # ### Authable/Ownerable.
    # ###

    def authable
      @authable ||= begin
        if totem_action_authorize?
          record = totem_action_authorize.record_authable
        else
          record = current_ability.get_authable_from_params_auth(params)
        end
        access_denied "Authable is blank."  if record.blank?
        record
      end
    end

    def ownerable
      @ownerable ||= begin
        if totem_action_authorize?
          record = totem_action_authorize.params_ownerable
        else
          record = current_ability.get_ownerable_from_params_auth(params)
        end
        access_denied "Ownerable is blank."  if record.blank?
        record
      end
    end

    # ###
    # ### Totem Action Authorize.
    # ###

    def new_totem_action_authorize(options={})
      auth_mod = get_action_authorize_module
      ::Totem::Core::Controllers::TotemActionAuthorize::Authorize.new(self, auth_mod, options)
    end

    def get_action_authorize_module
      access_denied "Authorize requires a params[:auth][:authable]."  unless authable.present?
      key = team? ? :action_authorize_teams : :action_authorize
      mod = ::Totem::Settings.module.send(:thinkspace).send(key)
      access_denied "Authorization module #{key.inspect} not found."  if mod.blank?
      mod
    end

    def totem_action_authorize?; self.send(:totem_action_authorize).present?; end

  end

end; end; end
