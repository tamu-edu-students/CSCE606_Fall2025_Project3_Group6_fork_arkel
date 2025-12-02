# Helper to login users in Cucumber
module DeviseTestHelpers
  def login_user(user)
    # Visit login page and submit form
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign In"
    # Wait a bit for redirect, then navigate to desired page
    sleep 0.3
  end
end

World(DeviseTestHelpers)
