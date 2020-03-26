require 'spec_helper.rb'
require 'rails_helper'

# RSpec.describe RequestsController, :type => :controller do 
describe "Navigating to a new request " do 
  before(:each) do 
    visit "/"
    fill_in 'email', with: "cassihardin@gmail.com"
    fill_in 'password', with: "tarjimlydocs19"
    click_button('Login')
  end
  it "should find the new request button" do
      visit "/requests"
      click_button 'New Request'
      expect(page).to have_current_path('/requests')          
  end
end

describe "Creating a new request" do
  before(:each) do 
    visit "/"
    fill_in 'email', with: "cassihardin@gmail.com"
    fill_in 'password', with: "tarjimlydocs19"
    click_button('Login')
    visit "/requests"
    click_button 'New Request'
  end

  it "should be able to fill in fields successfully" do
    fill_in 'request_title', with: 'Rspec Test'
    fill_in 'request_description', with: 'Rspec Test Description'
    fill_in 'request_document_text', with: 'Rspec Test Document'
    fill_in 'request_deadline', with: '03/25/2020 11:04 AM'
    select 'English', from: 'request_from_language'
    select 'Afar', from: 'request_to_language'
    click_button('Create Request')
    expect(page).to have_current_path('/requests')
  end

  it "should fail" do
    within("#new_request") do
      fill_in 'request_title', with: 'Rspec Test'
    end
    click_button 'Create Request'
    expect(page).to have_current_path('/requests')
  end

  # testing for disabled file upload

  # it "should be able to upload a file" do
  #   click_link("Upload File Instead")
  #   test_file = File.join(Rails.root, "test/fixtures/files/test.pdf")
  #   within("#new_request") do
  #     fill_in 'request_title', with: 'Rspec Upload Test'
  #     fill_in 'request_description', with: 'Rspec Test Description'
  #     fill_in 'request_deadline', with: '2097-08-08'
  #     attach_file('request_document_uploads', test_file)
  #     select 'English', from: 'request_from_language'
  #     select 'Arabic', from: 'request_to_language'
  #   end
  #   click_button 'Create Request'

    # page.should have_selector(:link_or_button, 'View')
   

    # click_button 'View'
    # expect(page).to have_text('pdf')
  # end

end

# describe RequestsController, type: :controller do
#   it "should redirect after failing" do
#     expect {
#       post :create, params: {request: {nil}}
#     }.should redirect_to("/requests/new")
#   end
# end

    