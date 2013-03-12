# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Forgery(:internet).email_address }
    provider 'facebook'
    external_user_id  { 100000000000000 + rand(1000000) }
    password { Forgery(:basic).password }
    first_name { Forgery(:name).first_name }
    last_name { Forgery(:name).last_name }
    confirmed_at { Time.now }
  end
end
