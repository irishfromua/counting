class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |u|
      u.text :username, null: false
      u.text :email,    null: false
      u.text :password, null: false
      u.text :salt,     null: false

      u.timestamps      null: false
    end
  end
end
