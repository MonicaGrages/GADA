describe "login", type: :feature do
  let(:email) { "admin@gadaatl.org" }
  let(:password) { "correct_password" }
  let(:user) { User.create!(email: email, password: password, password_confirmation: password) }

  it "logs the user in" do
    visit root_path
    click_link "Website Admin"
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button "Log in"
    expect(page).to have_content "Signed in successfully"
    expect(page).to have_current_path(root_path)
  end

  context "with invalid login credentials" do
    before do
      visit root_path
      click_link "Website Admin"
      fill_in 'Email', with: user.email
      fill_in 'Password', with: "incorrect_password"
      click_button "Log in"
    end

    it "does not log the user in" do
      expect(page).to have_content "Invalid Email or password"
      expect(page).to have_current_path(new_user_session_path)
    end

    it "does not allow access to admin menu" do
      visit admin_path
      expect(page).to have_content "Page cannot be found"
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
