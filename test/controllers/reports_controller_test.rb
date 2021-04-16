require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @report = reports(:one)
  end

  test "should get index" do
    get reports_url
    assert_response :success
  end

  test "should get new" do
    get new_report_url
    assert_response :success
  end

  test "should create report" do
    assert_difference('Report.count') do
      post reports_url, params: { report: { body: @report.body, customer_code: @report.customer_code, customer_name: @report.customer_name, discovery_stage: @report.discovery_stage, disposition: @report.disposition, number: @report.number, part: @report.part, part_name: @report.part_name, pieces: @report.pieces, pounds: @report.pounds, process_code: @report.process_code, purchase_order: @report.purchase_order, sent_on: @report.sent_on, shop_order: @report.shop_order, sub: @report.sub, user_id: @report.user_id, year: @report.year } }
    end

    assert_redirected_to report_url(Report.last)
  end

  test "should show report" do
    get report_url(@report)
    assert_response :success
  end

  test "should get edit" do
    get edit_report_url(@report)
    assert_response :success
  end

  test "should update report" do
    patch report_url(@report), params: { report: { body: @report.body, customer_code: @report.customer_code, customer_name: @report.customer_name, discovery_stage: @report.discovery_stage, disposition: @report.disposition, number: @report.number, part: @report.part, part_name: @report.part_name, pieces: @report.pieces, pounds: @report.pounds, process_code: @report.process_code, purchase_order: @report.purchase_order, sent_on: @report.sent_on, shop_order: @report.shop_order, sub: @report.sub, user_id: @report.user_id, year: @report.year } }
    assert_redirected_to report_url(@report)
  end

  test "should destroy report" do
    assert_difference('Report.count', -1) do
      delete report_url(@report)
    end

    assert_redirected_to reports_url
  end
end
