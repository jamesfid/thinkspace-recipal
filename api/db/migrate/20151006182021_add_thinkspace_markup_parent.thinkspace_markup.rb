# This migration comes from thinkspace_markup (originally 20151001000000)
class AddThinkspaceMarkupParent < ActiveRecord::Migration

  def change
    add_column :thinkspace_markup_comments, :parent_id, :integer
    add_column :thinkspace_markup_library_comments, :library_comment_id, :integer 
  end

end
