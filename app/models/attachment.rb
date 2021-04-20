class Attachment < ApplicationRecord

  # Allow uploads.
  has_one_attached  :file

  # Associations.
  belongs_to  :report

  # Validations.
  validates :name,
            presence: true
  validates :file,
            presence: true,
            blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf'] }

  # Callbacks.
  before_validation :set_attachment_name,
                    on: :create

  # Instance methods.

  # Sets name field for attachment record.
  def set_attachment_name
    return unless self.file.attached?
    self.name = self.file.filename
  end

end