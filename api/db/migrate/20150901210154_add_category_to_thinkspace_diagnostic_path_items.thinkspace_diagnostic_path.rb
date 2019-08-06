# This migration comes from thinkspace_diagnostic_path (originally 20150901000000)
class AddCategoryToThinkspaceDiagnosticPathItems < ActiveRecord::Migration
  def change
    add_column :thinkspace_diagnostic_path_path_items, :category, :json
  end
end
