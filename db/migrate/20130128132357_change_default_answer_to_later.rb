class ChangeDefaultAnswerToLater < ActiveRecord::Migration
  def change
    change_column :email_invites, :answer, :string, :default => "later"
  end
end
