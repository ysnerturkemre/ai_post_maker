class AddKindToPrompts < ActiveRecord::Migration[8.0]
  def change
    add_column :prompts, :kind, :string, null: false, default: "image"
  end
end
