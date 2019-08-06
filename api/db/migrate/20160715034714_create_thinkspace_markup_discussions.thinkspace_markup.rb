# This migration comes from thinkspace_markup (originally 20160622000000)
class CreateThinkspaceMarkupDiscussions < ActiveRecord::Migration
  def change

    create_table :thinkspace_markup_discussions, force: true do |t|
      t.references  :user
      t.references  :authable, polymorphic: true
      t.references  :ownerable, polymorphic: true
      t.references  :creatorable, polymorphic: true
      t.references  :discussionable, polymorphic: true
      t.json        :value, default: {}
      t.timestamps
      t.index  [:user_id],                                 name: :idx_thinkspace_markup_discussions_on_user
      t.index  [:authable_id, :authable_type],             name: :idx_thinkspace_markup_discussions_on_authable
      t.index  [:ownerable_id, :ownerable_type],           name: :idx_thinkspace_markup_discussions_on_ownerable
      t.index  [:creatorable_id, :creatorable_type],       name: :idx_thinkspace_markup_discussions_on_creatorable
      t.index  [:discussionable_id, :discussionable_type], name: :idx_thinkspace_markup_discussions_on_discussionable
    end

    add_column :thinkspace_markup_comments, :discussion_id, :integer
    add_column :thinkspace_markup_comments, :position, :integer

    # regression
    ActiveRecord::Base.transaction do
      Thinkspace::Markup::Comment.all.each do |comment|
        discussion                     = Thinkspace::Markup::Discussion.new
        discussion.user_id             = comment.user_id
        discussion.value[:position]    = {x: 0, y: comment.top}
        discussion.authable_type       = comment.authable_type
        discussion.authable_id         = comment.authable_id
        discussion.ownerable_type      = comment.ownerable_type
        discussion.ownerable_id        = comment.ownerable_id
        discussion.creatorable_type    = comment.commenterable_type
        discussion.creatorable_id      = comment.commenterable_id
        discussion.discussionable_type = comment.commentable_type
        discussion.discussionable_id   = comment.commentable_id
        discussion.save

        comment.discussion_id = discussion.id
        comment.position      = 0
        comment.save
      end
    end

    remove_column :thinkspace_markup_comments, :authable_type
    remove_column :thinkspace_markup_comments, :authable_id
    remove_column :thinkspace_markup_comments, :ownerable_type
    remove_column :thinkspace_markup_comments, :ownerable_id
    remove_column :thinkspace_markup_comments, :commentable_type
    remove_column :thinkspace_markup_comments, :commentable_id
    remove_column :thinkspace_markup_comments, :top

  end
end
