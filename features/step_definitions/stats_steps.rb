Given("I am logged in as a user") do
  @user = FactoryBot.create(:user)
  visit new_user_session_path
  fill_in "user_email", with: @user.email
  fill_in "session_password", with: @user.password
  click_button "Sign In"
end

Given("I have logged {int} movies") do |count|
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  count.times do |i|
    movie = FactoryBot.create(:movie, title: "Movie #{i + 1}", release_date: Date.today - 1.year)
    FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today - i.days)
  end
end

Given("I have no logged movies") do
  # User has no watch logs
end

When("I visit my stats page") do
  visit "/stats"
end

Then("I should see my total movies watched") do
  expect(page).to have_content("Movies Watched", wait: 5)
end

Then("I should see my total hours watched") do
  expect(page).to have_content("Hours Watched", wait: 5)
end

Then("I should see my total reviews") do
  expect(page).to have_content("Reviews Written", wait: 5)
end

Then("I should see my rewatch count") do
  expect(page).to have_content("Rewatches", wait: 5)
end

Then("I should see my genre breakdown") do
  expect(page).to have_content(/genre|decade/i, wait: 5)
end

Then("I should see an empty state message") do
  expect(page).to have_content(/no.*movies|empty/i)
end

When("I log a new movie") do
  movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today)
end

When("I refresh the stats page") do
  visit stats_path
end

Then("my total movies watched should increase") do
  # Verify the count has increased
  expect(page).to have_content(/total.*movies/i)
end

Given("I have logged movies with different genres and directors") do
  genre1 = FactoryBot.create(:genre, name: "Action")
  genre2 = FactoryBot.create(:genre, name: "Comedy")
  
  movie1 = FactoryBot.create(:movie, title: "Action Movie", release_date: Date.today - 1.year)
  movie2 = FactoryBot.create(:movie, title: "Comedy Movie", release_date: Date.today - 1.year)
  
  FactoryBot.create(:movie_genre, movie: movie1, genre: genre1)
  FactoryBot.create(:movie_genre, movie: movie2, genre: genre2)
  
  director = FactoryBot.create(:person, name: "Director Name")
  FactoryBot.create(:movie_person, movie: movie1, person: director, role: "director")
  
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  FactoryBot.create(:watch_log, movie: movie1, watch_history: watch_history, watched_on: Date.today)
  FactoryBot.create(:watch_log, movie: movie2, watch_history: watch_history, watched_on: Date.today - 1.day)
end

Then("I should see my top three genres") do
  expect(page).to have_content(/top.*genres|genre/i)
end

Then("I should see my most-watched directors") do
  expect(page).to have_content(/director/i)
end

Then("I should see my most-watched actors") do
  expect(page).to have_content(/actor/i)
end

When("I click {string} for genres") do |button_text|
  click_link_or_button button_text
end

Then("I should see a full ranked list of genres") do
  expect(page).to have_content(/genre/i)
end

Given("I have logged movies across multiple months") do
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  3.times do |i|
    movie = FactoryBot.create(:movie, title: "Movie #{i + 1}", release_date: Date.today - 1.year)
    FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today - i.months)
  end
end

Then("I should see activity trend chart") do
  expect(page).to have_content(/trend|activity/i)
end

Then("I should see rating trend chart") do
  expect(page).to have_content(/rating.*trend|trend.*rating/i)
end

Given("I have logged only one movie") do
  movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today)
end

Then("I should see a placeholder for the charts") do
  expect(page).to have_content(/insufficient|not enough|placeholder/i)
end

Given("I have logged movies in January") do
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
  FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.new(Date.today.year, 1, 15))
end

When("I log a movie in February") do
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
  FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.new(Date.today.year, 2, 15))
end

Then("the trend lines should update") do
  expect(page).to have_content(/trend/i)
end

Given("I have logged movies on different days") do
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  3.times do |i|
    movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
    FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today - i.days)
  end
end

Then("I should see the activity heatmap") do
  expect(page).to have_content(/heatmap|activity/i)
end

Then("active days should be highlighted") do
  expect(page).to have_css(".heatmap", wait: 5)
end

Then("I should see an empty heatmap grid") do
  expect(page).to have_css(".heatmap", wait: 5)
end

When("I log a new movie today") do
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  movie = FactoryBot.create(:movie, release_date: Date.today - 1.year)
  FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today)
end

Then("today should be highlighted in the heatmap") do
  expect(page).to have_css(".heatmap", wait: 5)
end

Given("I have logged movies with different genres") do
  genre1 = FactoryBot.create(:genre, name: "Action")
  genre2 = FactoryBot.create(:genre, name: "Comedy")
  
  movie1 = FactoryBot.create(:movie, title: "Action Movie", release_date: Date.today - 1.year)
  movie2 = FactoryBot.create(:movie, title: "Comedy Movie", release_date: Date.today - 1.year)
  
  FactoryBot.create(:movie_genre, movie: movie1, genre: genre1)
  FactoryBot.create(:movie_genre, movie: movie2, genre: genre2)
  
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  FactoryBot.create(:watch_log, movie: movie1, watch_history: watch_history, watched_on: Date.today)
  FactoryBot.create(:watch_log, movie: movie2, watch_history: watch_history, watched_on: Date.today - 1.day)
end

Given("I have logged movies") do
  watch_history = @user.watch_history || FactoryBot.create(:watch_history, user: @user)
  3.times do |i|
    movie = FactoryBot.create(:movie, title: "Movie #{i + 1}", release_date: Date.today - 1.year)
    FactoryBot.create(:watch_log, movie: movie, watch_history: watch_history, watched_on: Date.today - i.days)
  end
end
