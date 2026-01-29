# frozen_string_literal: true

class AddUserToPromptsAndPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :prompts, :user, foreign_key: true
    add_reference :posts, :user, foreign_key: true

    reversible do |dir|
      dir.up do
        user_id = select_value("SELECT id FROM users ORDER BY id LIMIT 1")
        if user_id
          execute("UPDATE prompts SET user_id = #{user_id} WHERE user_id IS NULL")
          execute(<<~SQL.squish)
            UPDATE posts
            SET user_id = prompts.user_id
            FROM prompts
            WHERE posts.prompt_id = prompts.id AND posts.user_id IS NULL
          SQL
        end

        prompts_null = select_value("SELECT COUNT(*) FROM prompts WHERE user_id IS NULL").to_i
        posts_null = select_value("SELECT COUNT(*) FROM posts WHERE user_id IS NULL").to_i

        if prompts_null > 0 || posts_null > 0
          raise ActiveRecord::IrreversibleMigration,
            "Cannot enforce user_id NOT NULL while prompts/posts have NULL user_id values."
        end

        change_column_null :prompts, :user_id, false
        change_column_null :posts, :user_id, false
      end
    end
  end
end
