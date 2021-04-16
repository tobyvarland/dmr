require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  setup do
    @report = reports(:one)
  end

  test "visiting the index" do
    visit reports_url
    assert_selector "h1", text: "Reports"
  end

  test "creating a Report" do
    visit reports_url
    click_on "New Report"

    fill_in "Body", with: @report.body
    fill_in "Customer code", with: @report.customer_code
    fill_in "Customer name", with: @report.customer_name
    fill_in "Discovery stage", with: @report.discovery_stage
    fill_in "Disposition", with: @report.disposition
    fill_in "Number", with: @report.number
    fill_in "Part", with: @report.part
    fill_in "Part name", with: @report.part_name
    fill_in "Pieces", with: @report.pieces
    fill_in "Pounds", with: @report.pounds
    fill_in "Process code", with: @report.process_code
    fill_in "Purchase order", with: @report.purchase_order
    fill_in "Sent on", with: @report.sent_on
    fill_in "Shop order", with: @report.shop_order
    fill_in "Sub", with: @report.sub
    fill_in "User", with: @report.user_id
    fill_in "Year", with: @report.year
    click_on "Create Report"

    assert_text "Report was successfully created"
    click_on "Back"
  end

  test "updating a Report" do
    visit reports_url
    click_on "Edit", match: :first

    fill_in "Body", with: @report.body
    fill_in "Customer code", with: @report.customer_code
    fill_in "Customer name", with: @report.customer_name
    fill_in "Discovery stage", with: @report.discovery_stage
    fill_in "Disposition", with: @report.disposition
    fill_in "Number", with: @report.number
    fill_in "Part", with: @report.part
    fill_in "Part name", with: @report.part_name
    fill_in "Pieces", with: @report.pieces
    fill_in "Pounds", with: @report.pounds
    fill_in "Process code", with: @report.process_code
    fill_in "Purchase order", with: @report.purchase_order
    fill_in "Sent on", with: @report.sent_on
    fill_in "Shop order", with: @report.shop_order
    fill_in "Sub", with: @report.sub
    fill_in "User", with: @report.user_id
    fill_in "Year", with: @report.year
    click_on "Update Report"

    assert_text "Report was successfully updated"
    click_on "Back"
  end

  test "destroying a Report" do
    visit reports_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Report was successfully destroyed"
  end
end
