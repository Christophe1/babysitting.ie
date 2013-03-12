class AddEmailToEmailInvites < ActiveRecord::Migration
  def change
    add_column :email_invites, :email, :string
  end
end
