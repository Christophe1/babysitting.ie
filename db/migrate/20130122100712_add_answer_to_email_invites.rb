class AddAnswerToEmailInvites < ActiveRecord::Migration
  def change
    add_column :email_invites, :answer, :string
  end
end
