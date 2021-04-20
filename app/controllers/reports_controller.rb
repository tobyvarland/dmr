class ReportsController < ApplicationController

  # Define filters available for has_scope gem.
  has_scope :sorted_by, only: :index
  has_scope :on_or_before, only: :index
  has_scope :on_or_after, only: :index
  has_scope :with_year, only: :index
  has_scope :with_customer, only: :index
  has_scope :with_process, only: :index
  has_scope :with_part, only: :index
  has_scope :with_shop_order, only: :index
  has_scope :with_discovery, only: :index
  has_scope :with_disposition, only: :index
  has_scope :entered_by, only: :index
  has_scope :containing, only: :index
  
  # Callbacks.
  before_action :set_report,
                only: %i[ show edit update destroy add_upload ]
  
  # Don't require login for view only.
  skip_before_action :authenticate_user!, only: [:show, :index, :monthly_report]

  def monthly_report
    unless params.include?(:year) && params.include?(:month)
      redirect_to monthly_report_url(year: Date.current.year, month: Date.current.month)
      return
    end
    @month = "#{sprintf('%02i', params[:month])}/#{params[:year]}"
    @reports = Report.for_monthly_report(params[:year], params[:month])
  end

  def index
    params[:sorted_by] = 'newest' if params[:sorted_by].blank?
    Report.destroy_unfinished
    begin
      @pagy, @reports = pagy(apply_scopes(Report.includes(:user).all), items: 20)
    rescue
      @pagy, @reports = pagy(apply_scopes(Report.includes(:user).all), items: 20, page: 1)
    end
  end

  def show
    authorize @report
    respond_to do |format|
      format.html { }
      format.pdf {
        dmr_pdf = ReportPdf.new(@report)
        count_pdf_attachments = 0
        files_to_combine = []
        @report.uploads.each do |file|
          next unless file.content_type == 'application/pdf'
          count_pdf_attachments += 1
          files_to_combine << ActiveStorage::Blob.service.path_for(file.key)
        end
        if count_pdf_attachments == 0
          send_data(dmr_pdf.render,
                    filename: "#{@report.dmr_number}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline')
        else
          combined = CombinePDF.parse(dmr_pdf.render)
          files_to_combine.each do |path|
            combined << CombinePDF.load(path)
          end
          send_data(combined.to_pdf,
                    filename: "#{@report.dmr_number}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline')
        end
      }
    end
  end

  def new
    @report = Report.new
    authorize @report
  end

  def edit
    authorize @report
  end

  def create
    @report = Report.new(report_params)
    authorize @report
    if @report.save
      redirect_to edit_report_path(@report)
    else
      redirect_to root_url, alert: "Could not create DMR. Double-check the shop order number and try again."
    end
  end

  def update
    authorize @report
    if @report.update(report_params)
      redirect_to @report
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @report
    @report.discard
    redirect_to root_url
  end

  def add_upload
    authorize @report
    params[:uploads].each do |upload|
      attachment = @report.attachments.new
      attachment.file = upload
      attachment.save
    end
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