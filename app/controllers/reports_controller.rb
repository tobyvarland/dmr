class ReportsController < ApplicationController

  # Callbacks.
  before_action :set_report,
                only: %i[ show edit update destroy add_upload ]
  
  # Don't require login for view only.
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    Report.with_discarded.where(entry_finished: false).destroy_all
    begin
      @pagy, @reports = pagy(Report.includes(:user).reverse_chronological, items: 50)
    rescue
      @pagy, @reports = pagy(Report.includes(:user).reverse_chronological, items: 50, page: 1)
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
      redirect_to reports_url, alert: "Could not create DMR. Double-check the shop order number and try again."
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
    redirect_to reports_url
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