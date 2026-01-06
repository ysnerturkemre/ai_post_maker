class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :prompt, null: false, foreign_key: true
      t.text :caption
      t.string :status
      t.string :kind
      t.json :data
      t.datetime :published_at
      t.datetime :scheduled_at

      t.timestamps
    end
  end
end
