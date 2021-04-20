class AttachmentsController < ApplicationController

  before_action :set_attachment, only: %i[ edit update destroy ]

  def edit
  end

  def update
    authorize @attachment
    if @attachment.update(attachment_params)
      redirect_to @attachment.report
    else
      redirect_to @attachment.report, error: "Error updating attachment. Please try again or contact IT for help."
    end
  end

  def destroy
    authorize @attachment
    @attachment.destroy
    redirect_to @attachment.report
  end

  private
    
    def set_attachment
      @attachment = Attachment.find(params[:id])
    end

    def attachment_params
      params.require(:attachment).permit(:name, :description, :report_id)
    end

end