# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  email                  :string(255)     default(""), not null
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  provider               :string(20)
#  external_user_id       :integer(8)
#  name                   :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  address                :text
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  lat                    :decimal(12, 9)
#  lng                    :decimal(12, 9)
#  address_visible        :boolean(1)      default(FALSE), not null
#  city                   :string(255)
#  draw                   :boolean(1)      default(FALSE), not null
#  invites                :integer(4)      default(0), not null
#

require 'spec_helper'

describe User do
  pending "add some examples to (or delete) #{__FILE__}"
end
