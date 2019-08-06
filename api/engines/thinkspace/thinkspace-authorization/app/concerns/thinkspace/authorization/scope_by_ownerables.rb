module Thinkspace
  module Authorization
    module ScopeByOwnerables

      extend ::ActiveSupport::Concern

      module ClassMethods

          # Rails 4.2 changed the return string from scope.where_sql by referencing
          # any variables by '?'.  Variables need to then be passed in a 'where' scope.
          # Previously (e.g. 4.1), the return string used '$' type references so common variables were shared (e.g. phase_id).
          # Removed 'where_sql' call and create the user and team sql strings manually (compatible with Rals 4.1 and 4.2).
          def scope_by_ownerables(user, record=nil)

            scope = scope_ownerable_table_sql(user.class.name, user.id)

            return where(scope)  if record.blank?

            teamable = nil
            if record.respond_to?(:thinkspace_team_teams)
              teamable = record
            else
              teamable = record.authable  if record.respond_to?(:authable)
            end

            if teamable.present? && teamable.respond_to?(:thinkspace_team_teams)
              team_ids = teamable.thinkspace_team_teams.scope_by_users(user).pluck(:id)
              if team_ids.present?
                scope += ' OR ' + scope_ownerable_table_sql(teamable.thinkspace_team_teams.klass.name, team_ids) 
              end
            end

            where(scope)
          end

          def scope_ownerable_table_sql(type, ids)
            scope  = '("' + self.table_name + '"."ownerable_type" = ' + "'#{type}'" + ' AND ' + '"' + self.table_name + '"."ownerable_id"'
            ids.instance_of?(Array) ? scope + ' IN (' + ids.join(', ') + '))' : scope + ' = ' + ids.to_s + ')'
          end

      end

    end
  end
end
