class CreateFilmsUsers < ActiveRecord::Migration
  def change
    create_table :films_users do |t|
      t.belongs_to :film
      t.belongs_to :user
    end
  end
end
