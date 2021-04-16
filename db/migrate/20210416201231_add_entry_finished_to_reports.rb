class AddEntryFinishedToReports < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :entry_finished, :boolean, null: false, default: false
  end
end