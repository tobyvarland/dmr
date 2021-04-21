class Report < ApplicationRecord

  # Soft deletes.
  include Discard::Model
  self.discard_column = :deleted_at

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
  has_many    :attachments

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

  # Callbacks.
  before_create     :set_report_date
  before_update     :set_entry_finished
  before_validation :set_year_and_number,
                    on: :create

  # Scopes.
  default_scope -> { kept }
  scope :sorted_by, ->(value) {
    return if value.blank?
    case value
    when 'shop_order'
      order(:shop_order)
    when 'part_spec'
      order(:customer_code, :process_code, :part, :sub)
    when 'newest'
      order(year: :desc, number: :desc)
    when 'oldest'
      order(:year, :number)
    end
  }
  scope :containing, ->(value) {
    return if value.blank?
    where("body LIKE (?)", "%#{value}%")
  }
  scope :entered_by, ->(value) {
    return if value.blank?
    where(user_id: value)
  }
  scope :with_disposition, ->(value) {
    return if value.blank?
    where(disposition: value)
  }
  scope :with_discovery, ->(value) {
    return if value.blank?
    where(discovery_stage: value)
  }
  scope :with_shop_order, ->(value) {
    return if value.blank?
    where(shop_order: value)
  }
  scope :with_part, ->(value) {
    return if value.blank?
    where(part: value)
  }
  scope :with_process, ->(value) {
    return if value.blank?
    where(process_code: value)
  }
  scope :with_customer, ->(value) {
    return if value.blank?
    where(customer_code: value)
  }
  scope :on_or_after, ->(value) {
    return if value.blank?
    where("sent_on >= ?", value)
  }
  scope :on_or_before,  ->(value) {
    return if value.blank?
    where("sent_on <= ?", value)
  }
  scope :with_year, ->(value) {
    return if value.blank?
    where(year: value)
  }
  scope :for_monthly_report, ->(year, month) {
    where("YEAR(`sent_on`) = ? AND MONTH(`sent_on`) = ?", year, month).order(:year, :number)
  }

  # Instance methods.
  
  # Sets entry finished flag before an update.
  def set_entry_finished
    self.entry_finished = true unless self.will_save_change_to_deleted_at?
  end

  # Returns DMR number (year & number).
  def dmr_number(plain = false)
    if plain
      return "#{self.year}-#{sprintf('%04i', self.number)}"
    else
      return "#{self.year}<span>-</span>#{sprintf('%04i', self.number)}"
    end
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
    last_dmr = Report.with_discarded.where(year: year).order(number: :desc).first
    self.number = last_dmr.blank? ? 1 : last_dmr.number + 1
  end

  # Class methods.

  # Destroys any DMRs that didn't finish the entry process.
  def self.destroy_unfinished
    Report.with_discarded.where(entry_finished: false).destroy_all
  end

end