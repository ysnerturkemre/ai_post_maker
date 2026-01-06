class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.references :post, null: false, foreign_key: true
      t.string :kind
      t.text :file_url
      t.integer :width
      t.integer :height
      t.integer :order_index

      t.timestamps
    end
  end
end
