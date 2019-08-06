# This migration comes from thinkspace_simulation (originally 20150715183057)
class CreateThinkspaceSimulationSimulation < ActiveRecord::Migration
  def change
    create_table :thinkspace_simulation_simulations, force: true do |t|
      t.string :title
      t.references :authable, polymorphic: true
      t.string :path
      t.timestamps
    end
  end
end
