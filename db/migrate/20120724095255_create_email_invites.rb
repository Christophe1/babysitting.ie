class CreateEmailInvites < ActiveRecord::Migration
  def change
    create_table :email_invites do |t|
      t.integer :from_user_id
      t.string  :token
      t.timestamps
    end

    add_index :email_invites, :token

  end
end
