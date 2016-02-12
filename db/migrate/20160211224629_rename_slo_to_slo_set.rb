class RenameSloToSloSet < ActiveRecord::Migration
  def change
    rename_table :slos, :slo_sets
  end
end
