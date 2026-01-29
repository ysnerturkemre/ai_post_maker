# frozen_string_literal: true

class AddComfyuiPromptIdToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :comfyui_prompt_id, :string
  end
end
