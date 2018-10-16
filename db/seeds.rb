role_list = [
    [ "ADMIN"],
    [ "CLIENT" ],
    [ "STYLIST" ],
]

role_list.each do |role|
  Role.create( :name => role[0] )
end

User.create(:first_name=>"Bharat",:last_name=>"bhate",:email=>"bharat@reddera.com",:stylist_type=>"",:description=>"",:password=>"bharat786",:role_id=>1,:admin=>true,:confirmed_at=>Time.now)
User.create(:first_name=>"Stylist",:last_name=>"Reddera",:email=>"redderastylist@gmail.com",:stylist_type=>"",:description=>"",:password=>"12345678",:role_id=>3,:confirmed_at=>Time.now)
User.create(:first_name=>"John",:last_name=>"Cooper",:email=>"sreddera01@gmail.com",:stylist_type=>"",:description=>"",:password=>"12345678",:role_id=>3,:confirmed_at=>Time.now)
User.create(:first_name=>"Professional",:last_name=>"Reddera",:email=>"sreddera02@gmail.com",:stylist_type=>"",:description=>"",:password=>"12345678",:role_id=>3,:confirmed_at=>Time.now)
ServiceCategory.create(:name=>"haircut")
ServiceSubCategory.create(:name=>"womens haircut",:service_category_id=>ServiceCategory.first.id)

5.times do
  pop=PopularService.new
  pop.service_sub_category_id=ServiceSubCategory.first.id.to_i
  pop.save
end

User.last(3).each  do|user|
  rec=RecentlyBooked.new
  rec.user_id=user.id
  rec.save
end

User.last(3).each  do|user|
  feat=FeaturedProfessional.new
  feat.user_id=user.id
  feat.save
end