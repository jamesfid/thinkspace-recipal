namespace :thinkspace do
  namespace :expert_path do
    task :reassign, [] => [:environment] do |t, args|
      viewer_id = ENV['VIEWER_ID']
      user_id   = ENV['USER_ID']
      raise "Cannot re-assign a viewer without a valid id." unless viewer_id.present?
      raise "Cannot re-assign a viewer without a valid user id." unless user_id.present?
      viewer = Thinkspace::DiagnosticPathViewer::Viewer.find_by(id: viewer_id)
      raise "Viewer ID passed in [#{viewer_id}] is not a valid Viewer." unless viewer.present?
      user = Thinkspace::Common::User.find_by(id: user_id)
      raise "User ID passed in [#{user_id}] is not a valid User." unless user.present?
      puts "[thinkspace:path_viewer:reassign] User is [#{user_id}] - viewer is [#{viewer_id}]"
      path = viewer.thinkspace_diagnostic_path_path
      raise "The viewer [#{viewer.inspect}] does not have a path, cannot continue." unless path.present?
      ownerable = viewer.ownerable
      raise "The viewer [#{viewer.inspect}] does not have an ownerable, cannot continue." unless ownerable.present?

      old_path_items = Thinkspace::DiagnosticPath::PathItem.where(ownerable: user, path_id: path.id)
      old_path_items.each do |o_path_item|
        path_itemable = o_path_item.path_itemable
        destroy_item(path_itemable) if path_itemable.present?
        destroy_item(o_path_item)
      end

      path_items = Thinkspace::DiagnosticPath::PathItem.where(ownerable: ownerable, path_id: path.id)
      path_items.each do |path_item|
        path_itemable = path_item.path_itemable
        reassign_item(path_itemable, user) if path_itemable.present?
        reassign_item(path_item, user)
      end

      reassign_item(viewer, user)
    end

    def destroy_item(record)
      puts "[thinkspace:path_viewer:reassign] Destroying record: [#{record.inspect}]"
      record.destroy
    end

    def reassign_item(record, user)
      puts "[thinkspace:path_viewer:reassign] Reassigning record: [#{record.inspect}] to [#{user.id}]"
      record.ownerable = user
      record.save
    end

  end
end