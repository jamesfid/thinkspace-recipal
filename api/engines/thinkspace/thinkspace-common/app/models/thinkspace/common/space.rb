module Thinkspace
  module Common
    class Space < ActiveRecord::Base
      totem_associations

      def self.totem_cache_query_key_index(scope, ownerable, options={})
        updated_ats = scope.joins(:thinkspace_casespace_assignments).merge(Thinkspace::Casespace::Assignment.open_updated_ats(ownerable))
        dates_ats   = scope.joins(:thinkspace_casespace_assignments).merge(Thinkspace::Casespace::Assignment.open_times(ownerable))
        [:assignments] + updated_ats.map(&:v_updated_at) + dates_ats.map(&:v_release_at)
      end

      def serializer_metadata(ownerable, so)
        ownerable        ||= so.current_user
        assignments        = self.thinkspace_casespace_assignments.accessible_by(so.current_ability, :read)
        hash               = Hash.new
        hash[:count]       = assignments.count
        hash[:open]        = assignments.scope_open(ownerable).count
        hash[:next_due_at] = assignments.next_due_at(ownerable)
        hash[:can_clone]   = true
        hash
      end

      def get_space; self; end

      def is_space_user?(user)
        return false if user.blank?
        user_id = user.respond_to?(:id) ? user.id : user
        self.thinkspace_common_space_users.where(user_id: user_id).exists?
      end

      # ###
      # ### AASM
      # ###

      include AASM
      aasm column: :state do
        state :neutral, initial: true
        state :active
        state :inactive
        event :activate do;   transitions to: :active; end
        event :inactivate do; transitions to: :inactive; end
      end

      # ###
      # ### Scopes.
      # ###

      def self.scope_active; active; end  # acitve = aasm auto-generated scope

      # ###
      # ### Invite.
      # ###

      def import_teams(files, sender)
        timestamp = Time.now.strftime('%Y-%m-%d %I:%M:%S')
        title     = "Teams Imported on #{timestamp}"
        team_set  = Thinkspace::Team::TeamSet.create(title: title, user_id: sender.id, space_id: self.id)
        records   = []
        begin
          user_class.transaction do
            files.each do |f|
              file    = f[:file]
              data    = f[:data]
              results = file.process(data)
              records = records | results
            end
            records.each do |r|
              user      = r[:record]
              row       = r[:row]
              team_name = row.fetch('team')
              user = process_imported_user(user, sender)
              process_imported_user_to_team(user, team_set, team_name)
            end
            notify_teams_import_complete(sender, nil, team_set)
          end
        rescue => e
          notify_teams_import_complete(sender, e, team_set)
        end
        return
      end

      def mass_invite(files, sender)
        records = []
        begin
          user_class.transaction do
            files.each do |f|
              file    = f[:file]
              data    = f[:data]
              results = file.process(data)
              records = records | results
            end
            records.each do |r|
              user = r[:record]
              process_imported_user(user, sender)
            end
            notify_roster_import_complete(sender, nil)
          end
        rescue => e
          notify_roster_import_complete(sender, e)
        end
        return records
      end

      def process_imported_user(user, sender, role='read')
        persisted_user = user_class.find_by(email: user.email)
        if persisted_user.present?
          space_user = space_user_class.find_by(space_id: self.id, user_id: persisted_user.id)
          unless space_user.present?
            space_user = space_user_class.create(space_id: self.id, user_id: persisted_user.id, role: role)
            space_user.activate!
            if persisted_user.active? then space_user.notify_added_to_space(sender) else space_user.notify_invited_to_space(sender) end
          end
        else
          if user.save
            space_user = space_user_class.create(space_id: self.id, user_id: user.id, role: role)
            space_user.activate!
            space_user.notify_invited_to_space(sender)
          end
        end
        if persisted_user.present? then persisted_user else user end
      end

      def process_invitation(invitation, auto=false)
        user        = invitation.thinkspace_common_user
        raise "Cannot process an invitation without a valid user. [#{invitation.inspect}]" unless user.present?
        space_users = self.thinkspace_common_space_users
        user_ids    = space_users.pluck(:user_id)
        if user_ids.include?(user.id)
          return true
        else
          role = invitation.role
          raise "Cannot process an invitation without a role. [#{invitation.inspect}]" unless role.present?
          space_user = Thinkspace::Common::SpaceUser.create(user_id: user.id, role: role, space_id: self.id)
          if space_user.present?
            space_user.notify_added_to_space(Thinkspace::Common::User.find(invitation.sender_id)) if auto
            true
          else
            false
          end
        end
      end

      def process_imported_user_to_team(user, team_set, team_name)
        raise "Cannot add to team without a valid user." unless user.present?
        raise "Cannot add user [#{user.id}] to a team set without a valid team set." unless team_set.present?
        team = team_set.thinkspace_team_teams.find_or_create_by(title: team_name, authable: self)
        raise "Cannot add user to a team, team is invalid [#{team.inspect}]" unless team and !team.errors.present?
        team.thinkspace_common_users << user
      end

      def notify_roster_import_complete(sender, status)
        notification_mailer_class.roster_imported(sender, status, self).deliver_now
      end

      def notify_teams_import_complete(sender, status, team_set)
        notification_mailer_class.teams_imported(sender, status, team_set, self).deliver_now
      end

      # ###
      # ### Clone Space
      # ###

      include ::Totem::Settings.module.thinkspace.deep_clone_helper

      def cyclone_with_notification(user, options={})
        begin
          cloned_space = cyclone(options)
          notification_mailer_class.space_clone_completed(user, self, cloned_space).deliver_now
        rescue
          notification_mailer_class.space_clone_failed(user, self).deliver_now
        end
      end
      handle_asynchronously :cyclone_with_notification

      def cyclone(options={})
        self.transaction do
          options[:dictionary] ||= get_clone_dictionary(options)
          clone_associations = get_clone_associations(options)
          cloned_space       = clone_self(options, clone_associations)
          cloned_space.title = get_clone_title(self.title, options)
          clone_save_record(cloned_space)
          options.merge!(keep_title: true, is_full_clone: true)
          # The 'associations.yml' has the space's assignments as readonly.
          # Doing a 'deep_clone' of an assignment will raise:
          #   "ActiveRecord::ReadOnlyRecord: Thinkspace::Casespace::Assignment is marked as readonly"
          # (even though the assignment is not updated).
          assignments = thinkspace_casespace_assignments.readonly(false)
          assignments.each do |assignment|
            assignment.cyclone(options)
          end
          cloned_space.clone_instructors(self)
          cloned_space
        end
      end

      def clone_instructors(original_space)
        raise_clone_exception("Cannot clone instructors without an original space.") if original_space.blank?
        instructor_roles = ['update', 'owner']
        space_users      = original_space.thinkspace_common_space_users.where(role: instructor_roles)
        space_users.each do |su|
          self.thinkspace_common_space_users << Thinkspace::Common::SpaceUser.create(user_id: su.user_id, role: su.role, state: 'active')
        end
      end

      def add_user_as_owner(user)
        add_user_as_role(user, 'owner')
      end

      private

      def get_clone_associations(options={})
        clone_associations = [:thinkspace_common_space_space_types]  # add cloned space to space_space_types table
        clone_associations
      end

      def add_user_as_role(user, role)
        return if thinkspace_common_space_users.include?(user)
        thinkspace_common_space_users << Thinkspace::Common::SpaceUser.create(thinkspace_common_user: user, role: role, state: 'active')
      end

      def invitation_class; Thinkspace::Common::Invitation; end
      def user_class; Thinkspace::Common::User; end
      def space_user_class; Thinkspace::Common::SpaceUser; end
      def notification_mailer_class; Thinkspace::Common::NotificationMailer; end

      # ###
      # ### Delete Ownerable Data.
      # ###

      public

      def delete_all_ownerable_data!
        self.transaction do
          self.thinkspace_casespace_assignments.each do |assignment|
            assignment.delete_all_ownerable_data!
          end
        end
      end

      def delete_ownerable_data(ownerables)
        self.transaction do
          self.thinkspace_casespace_assignments.each do |assignment|
            assignment.delete_ownerable_data(ownerables)
          end
        end
      end


    end
  end
end
