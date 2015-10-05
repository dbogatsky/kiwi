class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, unique: true, null: false
      t.string :email, unique: true, null: false
      t.string :password, unique: true, null: false
      t.string :first_name
      t.string :last_name

      t.timestamps null: false
    end
  end
end
