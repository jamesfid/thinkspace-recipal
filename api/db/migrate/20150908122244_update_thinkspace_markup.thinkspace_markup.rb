# This migration comes from thinkspace_markup (originally 20150901000000)
class UpdateThinkspaceMarkup < ActiveRecord::Migration
  def change

    create_table :thinkspace_markup_libraries, force: true do |t|
      t.references :user
      t.timestamps
    end

    create_table :thinkspace_markup_library_comments, force: true do |t|
      t.references   :user
      t.references   :library
      t.text         :comment
      t.integer      :uses
      t.date         :last_used
      t.timestamps
    end

  end
end
