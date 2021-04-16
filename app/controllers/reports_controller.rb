class ReportsController < ApplicationController

  # Callbacks.
  before_action :set_report,
                only: %i[ show edit update destroy add_upload ]
  
  # Don't require login for view only.
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    Report.where(entry_finished: false).destroy_all
    @reports = Report.includes(:user).all
  end

  def show
  end

  def new
    @report = Report.new
  end

  def edit
  end

  def create
    @report = Report.new(report_params)
    if @report.save
      redirect_to edit_report_path(@report)
    else
      redirect_to reports_url, alert: "Could not create DMR. Double-check the shop order number and try again."
    end
  end

  def update
    if @report.update(report_params)
      redirect_to @report
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy
    redirect_to reports_url
  end

  def remove_upload
    upload = ActiveStorage::Attachment.find(params[:id])
    upload.purge_later
    redirect_to(report_path(upload.record))
  end

  def add_upload
    @report.uploads.attach(params[:uploads])
    redirect_to(@report)
  end

  private

    def set_report
      @report = Report.find(params[:id])
    end

    def report_params
      params.require(:report).permit(:year, :number, :shop_order, :customer_code, :process_code, :part, :sub, :sent_on, :discovery_stage, :disposition, :pounds, :pieces, :customer_name, :part_name, :purchase_order, :user_id, :body)
    end
    
end