Admin.create(:email => "admin@qs.com", :password => "qwerty_123")

#unless Rails.env.production?
#  1000.times do
#    Factory.create(:user)
#  end
#end

categories_file = File.join(Rails.root, 'config', 'categories.txt')
if File.exists?(categories_file)
  File.open(categories_file, 'r') do |f|
    while category = f.gets
      Category.create(:name => category)
    end
  end
end