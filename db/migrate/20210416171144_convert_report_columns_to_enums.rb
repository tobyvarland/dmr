class ConvertReportColumnsToEnums < ActiveRecord::Migration[6.1]
  def up
    execute "ALTER TABLE `reports` MODIFY `discovery_stage` ENUM('before', 'during', 'after');"
    execute "ALTER TABLE `reports` MODIFY `disposition` ENUM('unprocessed', 'partial', 'complete');"
  end
  def down
    change_column :reports, :discovery_stage, :string
    change_column :reports, :disposition, :string
  end
end