Given("I am a registered user") do
  @user = FactoryBot.create(:user)
end

When("I sign in with valid credentials") do
  visit new_user_session_path
  fill_in "user_email", with: @user.email
  fill_in "session_password", with: @user.password
  click_button "Sign In"
end

When("I attempt to sign in with an invalid password") do
  visit new_user_session_path
  fill_in "user_email", with: @user.email
  fill_in "session_password", with: "wrongpassword"
  click_button "Sign In"
end

Then("I should be signed in") do
  expect(page).to have_button("Log Out")
end

When("I open the sign in page from the navbar") do
  visit root_path
  click_link "Sign In"
end

Then("I should see the sign in form") do
  expect(page).to have_content("Sign In")
  expect(page).to have_field("user_email")
end

Then("I should see a sign in error") do
  expect(page).to have_content(/invalid email or password/i)
end

Given("I am signed in") do
  step "I sign in with valid credentials"
end

When("I sign out") do
  click_button "Log Out"
end

Then("I should be signed out") do
  expect(page).to have_link("Sign In")
end

When("I visit my profile page") do
  visit profile_path
end

Then("I should see my username on the profile") do
  expect(page).to have_content(@user.username)
end

Then("I should see my lists section") do
  expect(page).to have_content(/Your Lists|Public Lists/i)
end

Given("there is a private user named {string}") do |username|
  @other_user = FactoryBot.create(:user, username: username, profile_public: false)
end

Given("I have a notification") do
  @user ||= FactoryBot.create(:user)
  @notification = FactoryBot.create(:notification, recipient: @user, body: "You have a new follower")
end

Given("I have multiple unread notifications") do
  @user ||= FactoryBot.create(:user)
  FactoryBot.create_list(:notification, 2, recipient: @user, body: "Unread notice", read: false)
end

When("I visit my notifications page") do
  visit notifications_path
end

Then("I should see my notification") do
  expect(page).to have_content(@notification.body)
end

Then("I can mark it as read") do
  if page.has_button?("Mark read", wait: 5)
    click_button("Mark read", match: :first)
  end
  expect(page).to have_no_button("Mark read", wait: 5)
end

When("I mark all notifications as read") do
  click_button "Mark all read"
end

Then("I should not see unread notification actions") do
  expect(page).to have_no_button("Mark read", wait: 5)
end
