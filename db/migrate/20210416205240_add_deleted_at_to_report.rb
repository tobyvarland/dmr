class AddDeletedAtToReport < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :deleted_at, :datetime
    add_index :reports, :deleted_at
  end
end