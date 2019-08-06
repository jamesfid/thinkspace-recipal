# This migration comes from thinkspace_markup (originally 20150501000000)
class CreateThinkspaceMarkup < ActiveRecord::Migration
  def change

    create_table :thinkspace_markup_comments, force: true do |t|
      t.references  :user
      t.references  :authable, polymorphic: true
      t.references  :ownerable, polymorphic: true
      t.references  :commenterable, polymorphic: true
      t.references  :commentable, polymorphic: true
      t.float       :top
      t.text        :comment
      t.timestamps
      t.index  [:user_id],                                name: :idx_thinkspace_markup_comments_on_user
      t.index  [:authable_id, :authable_type],            name: :idx_thinkspace_markup_comments_on_authable
      t.index  [:ownerable_id, :ownerable_type],          name: :idx_thinkspace_markup_comments_on_ownerable
      t.index  [:commenterable_id, :commenterable_type],  name: :idx_thinkspace_markup_comments_on_commenterable
      t.index  [:commentable_id, :commentable_type],      name: :idx_thinkspace_markup_comments_on_commentable
    end

  end
end
