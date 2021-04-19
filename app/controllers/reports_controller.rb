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
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    params[:sorted_by] = 'newest' if params[:sorted_by].blank?
    @filters = {}
    @filters[:on_or_before] = params.fetch(:on_or_before, nil)
    @filters[:on_or_after] = params.fetch(:on_or_after, nil)
    @filters[:with_year] = params.fetch(:with_year, nil)
    @filters[:with_customer] = params.fetch(:with_customer, nil)
    @filters[:with_process] = params.fetch(:with_process, nil)
    @filters[:with_part] = params.fetch(:with_part, nil)
    @filters[:with_shop_order] = params.fetch(:with_shop_order, nil)
    @filters[:with_discovery] = params.fetch(:with_discovery, nil)
    @filters[:with_disposition] = params.fetch(:with_disposition, nil)
    @filters[:entered_by] = params.fetch(:entered_by, nil)
    @filters[:containing] = params.fetch(:containing, nil)
    Report.destroy_unfinished
    begin
      @pagy, @reports = pagy(apply_scopes(Report.includes(:user).all), items: 50)
    rescue
      @pagy, @reports = pagy(apply_scopes(Report.includes(:user).all), items: 50, page: 1)
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

  def remove_upload
    upload = ActiveStorage::Attachment.find(params[:id])
    authorize upload.record
    upload.purge_later
    redirect_to(report_path(upload.record))
  end

  def add_upload
    authorize @report
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