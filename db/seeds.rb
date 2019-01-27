# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
if MenuItem.where({id: 1}).first == nil
  MenuItem.create({})
end

if User.where({email: "admin@doe.com"}).first == nil
  user = User.new({email: "admin@doe.com", password: "123456", password_confirmation: "123456"})
  user.profile = Profile.new({name: "Joe Doe"})
  ["root", "admin", "doctor", "patient", "blogger", "appointment_scheduler"].each do |it|
    user.add_role(it)
  end
  user.save()
end
if Page.where({title: "about-us"}).first == nil
  Page.create(title: 'about-us', body: 'hello world!')
end