# == Schema Information
#
# Table name: admins
#
#  id                  :integer(4)      not null, primary key
#  email               :string(255)     default(""), not null
#  encrypted_password  :string(255)     default(""), not null
#  remember_created_at :datetime
#  sign_in_count       :integer(4)      default(0)
#  current_sign_in_at  :datetime
#  last_sign_in_at     :datetime
#  current_sign_in_ip  :string(255)
#  last_sign_in_ip     :string(255)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#

require 'spec_helper'

describe Admin do
  pending "add some examples to (or delete) #{__FILE__}"
end
