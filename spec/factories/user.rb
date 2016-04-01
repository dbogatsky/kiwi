FactoryGirl.define do
  factory :user,class: "User" do
  	sequence(:email) {|n|
      "foo#{n}@bar.com"
    }
    sequence(:email_confirmation) {|n|
      "foo#{n}@bar.com"
    }
  	first_name Faker::Name.name
  	last_name Faker::Name.name
  	password "ongraph@123"
  	password_confirmation "ongraph@123"
  end
end