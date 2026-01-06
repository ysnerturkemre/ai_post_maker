class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts do |t|
      t.text :text
      t.string :lang
      t.string :tone

      t.timestamps
    end
  end
end
