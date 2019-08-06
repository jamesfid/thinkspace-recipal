# This migration comes from thinkspace_html (originally 20150501000000)
class CreateThinkspaceHtml < ActiveRecord::Migration
  def change

    create_table :thinkspace_html_contents, force: true do |t|
      t.references  :authable, polymorphic: true
      t.text        :html_content
      t.timestamps
      t.index  [:authable_id, :authable_type],  name: :idx_thinkspace_htmls_contents_on_authable
    end

  end
end
