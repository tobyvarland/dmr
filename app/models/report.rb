class Report < ApplicationRecord

  # Allow uploads.
  has_many_attached :uploads

  # Serialization.
  serialize :part_name
  serialize :customer_name
  serialize :purchase_order

  # Enumerations.
  enum discovery_stage: {
    before: "before",
    during: "during",
    after: "after"
  }
  enum disposition: {
    unprocessed: "unprocessed",
    partial: "partial",
    complete: "complete"
  }

  # Associations.
  belongs_to  :user

  # Validations.
  validates :year,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 2020 }
  validates :number,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :year }
  validates :shop_order,
            presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than: 1000000 }
  validates :shop_order,
            shop_order: true,
            on: :create
  validates :customer_code, :process_code, :part, :part_name, :customer_name,
            presence: true
  validates :pounds,
            presence: true,
            numericality: { greater_than: 0 }
  validates :pieces,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :body,
            presence: true,
            on: :update
  validates :discovery_stage,
            presence: true,
            on: :update
  validates :disposition,
            presence: true,
            on: :update
  validates :uploads,
            blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf'] }

  # Callbacks.
  before_create     :set_report_date
  before_update     :set_entry_finished
  before_validation :set_year_and_number,
                    on: :create

  # Instance methods.
  
  # Sets entry finished flag before an update.
  def set_entry_finished
    self.entry_finished = true
  end

  # Returns DMR number (year & number).
  def dmr_number
    return "#{self.year}-#{sprintf('%04i', self.number)}"
  end

  # Returns part spec fields.
  def part_spec
    fields = [self.customer_code, self.process_code, self.part]
    fields << self.sub unless self.sub.blank?
    return fields
  end

  # Sets date to current date.
  def set_report_date
    return unless self.sent_on.blank?
    self.sent_on = Date.current
  end

  # Sets year and number.
  def set_year_and_number
    year = Date.current.year
    self.year = year
    last_dmr = Report.where(year: year).order(number: :desc).first
    self.number = last_dmr.blank? ? 1 : last_dmr.number + 1
  end

end