class CreateThings < ActiveRecord::Migration
  def change
    create_table :things do |t|
      t.integer :user_id, null: false
      t.text    :title,   null: false
      t.integer :count,   null: false

      t.timestamps        null: false
    end
  end
end
