require "rails_helper"

RSpec.describe "Books", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  it "ログインして本を投稿できる" do
    visit new_session_path

    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_button "Log in"

    visit books_path

    fill_in "book[title]", with: "システムテスト本"
    fill_in "book[body]", with: "これはシステムテストです"
    fill_in "book[category]", with: "技術"
    fill_in "book[score]", with: 4

    click_button "Create Book"

    expect(page).to have_content "システムテスト本"
  end
end