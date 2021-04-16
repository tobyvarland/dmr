class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.integer     :year,            null: false
      t.integer     :number,          null: false
      t.integer     :shop_order,      null: false
      t.string      :customer_code,   null: false,  limit: 6
      t.string      :process_code,    null: false,  limit: 3
      t.string      :part,            null: false,  limit: 17
      t.string      :sub,             null: true,   default: nil, limit: 1
      t.date        :sent_on,         null: false
      t.string      :discovery_stage, null: true,   default: nil
      t.string      :disposition,     null: true,   default: nil
      t.float       :pounds,          null: true,   default: nil
      t.integer     :pieces,          null: true,   default: nil
      t.string      :customer_name,   null: false
      t.string      :part_name,       null: false
      t.string      :purchase_order,  null: true,   default: nil
      t.references  :user,            null: false,  foreign_key: true
      t.text        :body,            null: true,   default: nil
      t.timestamps
    end
    add_index :reports, [:year, :number], unique: true, name: "unique_dmr_number"
  end
end