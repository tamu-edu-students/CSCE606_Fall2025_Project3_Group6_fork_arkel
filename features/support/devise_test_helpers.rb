# Helper to login users in Cucumber
module DeviseTestHelpers
  def login_user(user)
    # Ensure user has a password
    password = user.password || "password123"
    user.update(password: password) if user.password.blank?
    
    # Visit login page and submit form
    visit new_user_session_path
    begin
      fill_in "Email", with: user.email
      fill_in "Password", with: password
      click_button "Sign In"
    rescue Capybara::ElementNotFound => e
      # Try alternative selectors
      begin
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: password
        find('input[type="submit"]').click
      rescue Capybara::ElementNotFound
        # Last resort: try to find any email/password fields
        find('input[type="email"], input[name*="email"]').set(user.email)
        find('input[type="password"], input[name*="password"]').set(password)
        find('input[type="submit"], button[type="submit"]').click
      end
    end
    # Wait a bit for redirect
    sleep 0.5
  end
end

World(DeviseTestHelpers)
