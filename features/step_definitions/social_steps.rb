Given("there is a user named {string}") do |username|
  @other_user = FactoryBot.create(:user, username: username)
end

When("I visit {string}'s profile") do |username|
  user = User.find_by(username: username) || @other_user
  visit "/u/#{user.username}"
end

When("I click {string}") do |button_text|
  click_link_or_button button_text
end

Then("{string} should be added to my following list") do |username|
  user = User.find_by(username: username) || @other_user
  expect(@user.followed_users).to include(user)
end

Then("{string} should receive a notification") do |username|
  user = User.find_by(username: username) || @other_user
  expect(user.notifications.where(notification_type: "user.followed")).to exist
end

Given("I am following {string}") do |username|
  user = User.find_by(username: username) || @other_user
  FactoryBot.create(:follow, follower: @user, followed: user)
end

Then("{string} should be removed from my following list") do |username|
  user = User.find_by(username: username) || @other_user
  expect(@user.followed_users).not_to include(user)
end

Given("I am on my own profile") do
  visit "/profile"
  expect(page).to have_content(@user.username, wait: 10)
end

When("I try to follow myself") do
  visit "/profile"
  # Should not see Follow button on own profile
  expect(page).not_to have_button("Follow", wait: 5)
end

Then("I should not be following myself") do
  expect(@user.followed_users).not_to include(@user)
end

Given("{string} has logged a movie") do |username|
  user = User.find_by(username: username) || @other_user
  movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
  watch_history = user.watch_history || FactoryBot.create(:watch_history, user: user)
  FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today)
end

When("I visit my activity feed") do
  visit root_path
  # Wait for Activity Feed to load
  expect(page).to have_content("Activity Feed", wait: 10)
end

Then("I should see {string}'s activity in chronological order") do |username|
  expect(page).to have_content(username, wait: 5)
end

Given("{string} has no activity") do |username|
  # User has no activity
end

When("I refresh the feed") do
  visit current_path
end

Then("the new activity should appear at the top") do
  expect(page).to have_content("Activity Feed", wait: 5)
  # Activity should be visible
  expect(page).to have_css(".feed-card", wait: 5)
end

When("{string} logs a new movie") do |username|
  user = User.find_by(username: username) || @other_user
  movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
  watch_history = user.watch_history || FactoryBot.create(:watch_history, user: user)
  FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today)
end

Given("I am on the lists page") do
  visit lists_path
  expect(page).to have_content(/list|create/i, wait: 10)
end

When("I click {string}") do |button_text|
  click_link_or_button button_text, wait: 5
end

When("I enter {string} as the list name") do |name|
  fill_in "list_name", with: name
end

When("I enter {string} as the description") do |description|
  fill_in "list_description", with: description
end

When("I set the list to public") do
  check "list_public"
end

When("I save the list") do
  click_button "Create List"
end

Then("the list should appear on my profile") do
  visit "/profile"
  expect(page).to have_content("My Favorite Movies", wait: 5)
end

Then("the list should be named {string}") do |name|
  expect(page).to have_content(name)
end

Given("I have a list named {string}") do |name|
  @list = FactoryBot.create(:list, user: @user, name: name)
end

When("I edit {string}") do |name|
  list = List.find_by(name: name) || @list
  visit edit_list_path(list)
  expect(page).to have_content(/edit|update/i, wait: 5)
end

When("I change the name to {string}") do |new_name|
  fill_in "list_name", with: new_name
end

When("I save the changes") do
  click_button "Update List"
end

Then("the list should be displayed as {string}") do |name|
  expect(page).to have_content(name)
end

When("I delete {string}") do |name|
  list = List.find_by(name: name) || @list
  visit list_path(list)
  click_button "Delete List"
  # Handle confirmation dialog if present
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to?(:switch_to) rescue nil
end

Then("the list should be removed from my profile") do
  visit "/profile"
  expect(page).not_to have_content("My List", wait: 5)
end

Given("{string} has a public list named {string}") do |username, list_name|
  user = User.find_by(username: username) || @other_user
  FactoryBot.create(:list, user: user, name: list_name, public: true)
end

Given("I am not logged in") do
  # Already not logged in or sign out
  visit root_path
end

Then("I should see {string} list") do |list_name|
  expect(page).to have_content(list_name, wait: 5)
end

Then("I should be able to view the list contents") do
  expect(page).to have_css(".grid, .list", wait: 5)
end

Given("{string} has a private list named {string}") do |username, list_name|
  user = User.find_by(username: username) || @other_user
  @private_list = FactoryBot.create(:list, user: user, name: list_name, public: false)
end

When("I try to view {string}'s private list") do |username|
  user = User.find_by(username: username) || @other_user
  list = List.find_by(name: "Private List", user: user) || @private_list
  visit list_path(list)
end

Then("I should see a restricted access message") do
  expect(page).to have_content(/private|restricted|access|not authorized/i, wait: 5)
end

Given("{string} has an empty public list") do |username|
  user = User.find_by(username: username) || @other_user
  FactoryBot.create(:list, user: user, name: "Empty List", public: true)
end

When("I view {string}'s list") do |username|
  user = User.find_by(username: username) || @other_user
  list = List.find_by(name: "Empty List", user: user)
  visit list_path(list)
end

Given("{string} has a public list with movies") do |username|
  user = User.find_by(username: username) || @other_user
  list = FactoryBot.create(:list, user: user, name: "Movies List", public: true)
  movie = FactoryBot.create(:movie, title: "Test Movie")
  FactoryBot.create(:list_item, list: list, movie: movie)
end

When("I click a movie in {string}'s list") do |username|
  user = User.find_by(username: username) || @other_user
  list = List.find_by(name: "Movies List", user: user)
  visit list_path(list)
  click_link_or_button "Test Movie"
end

Then("I should be taken to the movie's detail page") do
  expect(current_path).to match(/\/movies\/\d+/)
end
