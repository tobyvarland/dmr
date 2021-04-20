class CreateAttachments < ActiveRecord::Migration[6.1]
  def change
    create_table :attachments do |t|
      t.string      :name,        null: false,  default: nil
      t.string      :description, null: true,   default: nil
      t.references  :report,      null: false,  foreign_key: true
      t.timestamps
    end
  end
end