RSpec.describe "Buying a story as a user" do
    context "when a user creates an account and buys a story" do
        it "displays the story that has been bought" do
        
            visit '/create-account'
            fill_in 'username', with: 'testuser'
            fill_in 'password', with: 'Testpassword'
            fill_in 'confirm_password', with: 'Testpassword'
            fill_in 'dob', with: '1990-01-01'
            fill_in 'email', with: 'test1@example.com'
            choose "reader"
            click_button('Create Account')

            user = User.where(username: 'testuser').first
            user.popcorns = 100

            click_link "title"

            click_button "Buy Story"
            save_page
            expect(page).to have_content('Thank you for purchasing')
        end
    end
end