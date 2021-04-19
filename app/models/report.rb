class Report < ApplicationRecord

  # Soft deletes.
  include Discard::Model
  self.discard_column = :deleted_at

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

  # Instance methods.
  
  # Sets entry finished flag before an update.
  def set_entry_finished
    self.entry_finished = true unless self.will_save_change_to_deleted_at?
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
    last_dmr = Report.with_discarded.where(year: year).order(number: :desc).first
    self.number = last_dmr.blank? ? 1 : last_dmr.number + 1
  end

  # Class methods.

  # Destroys any DMRs that didn't finish the entry process.
  def self.destroy_unfinished
    Report.with_discarded.where(entry_finished: false).destroy_all
  end

  # Get filter options for year.
  def self.year_options(filters)
    return [filters[:with_year]] unless filters[:with_year].blank?
    return Report
            .on_or_before(filters[:on_or_before])
            .on_or_after(filters[:on_or_after])
            .with_year(filters[:with_year])
            .with_customer(filters[:with_customer])
            .with_process(filters[:with_process])
            .with_part(filters[:with_part])
            .with_shop_order(filters[:with_shop_order])
            .with_discovery(filters[:with_discovery])
            .with_disposition(filters[:with_disposition])
            .entered_by(filters[:entered_by])
            .containing(filters[:containing])
            .distinct.pluck(:year).sort
  end

  # Get filter options for customer.
  def self.customer_options(filters)
    return [filters[:with_customer]] unless filters[:with_customer].blank?
    return Report
            .on_or_before(filters[:on_or_before])
            .on_or_after(filters[:on_or_after])
            .with_year(filters[:with_year])
            .with_customer(filters[:with_customer])
            .with_process(filters[:with_process])
            .with_part(filters[:with_part])
            .with_shop_order(filters[:with_shop_order])
            .with_discovery(filters[:with_discovery])
            .with_disposition(filters[:with_disposition])
            .entered_by(filters[:entered_by])
            .containing(filters[:containing])
            .distinct.pluck(:customer_code).sort
  end

  # Get filter options for process.
  def self.process_options(filters)
    return [filters[:with_process]] unless filters[:with_process].blank?
    return Report
            .on_or_before(filters[:on_or_before])
            .on_or_after(filters[:on_or_after])
            .with_year(filters[:with_year])
            .with_customer(filters[:with_customer])
            .with_process(filters[:with_process])
            .with_part(filters[:with_part])
            .with_shop_order(filters[:with_shop_order])
            .with_discovery(filters[:with_discovery])
            .with_disposition(filters[:with_disposition])
            .entered_by(filters[:entered_by])
            .containing(filters[:containing])
            .distinct.pluck(:process_code).sort
  end

  # Get filter options for part.
  def self.part_options(filters)
    return [filters[:with_part]] unless filters[:with_part].blank?
    return Report
            .on_or_before(filters[:on_or_before])
            .on_or_after(filters[:on_or_after])
            .with_year(filters[:with_year])
            .with_customer(filters[:with_customer])
            .with_process(filters[:with_process])
            .with_part(filters[:with_part])
            .with_shop_order(filters[:with_shop_order])
            .with_discovery(filters[:with_discovery])
            .with_disposition(filters[:with_disposition])
            .entered_by(filters[:entered_by])
            .containing(filters[:containing])
            .distinct.pluck(:part).sort
  end

  # Get filter options for shop order.
  def self.shop_order_options(filters)
    return [filters[:with_shop_order]] unless filters[:with_shop_order].blank?
    return Report
            .on_or_before(filters[:on_or_before])
            .on_or_after(filters[:on_or_after])
            .with_year(filters[:with_year])
            .with_customer(filters[:with_customer])
            .with_process(filters[:with_process])
            .with_part(filters[:with_part])
            .with_shop_order(filters[:with_shop_order])
            .with_discovery(filters[:with_discovery])
            .with_disposition(filters[:with_disposition])
            .entered_by(filters[:entered_by])
            .containing(filters[:containing])
            .distinct.pluck(:shop_order).sort
  end

  # Get filter options for discovery stage.
  def self.discovery_options(filters)
    raw = []
    if filters[:with_discovery].blank?
      raw = Report
              .on_or_before(filters[:on_or_before])
              .on_or_after(filters[:on_or_after])
              .with_year(filters[:with_year])
              .with_customer(filters[:with_customer])
              .with_process(filters[:with_process])
              .with_part(filters[:with_part])
              .with_shop_order(filters[:with_shop_order])
              .with_discovery(filters[:with_discovery])
              .with_disposition(filters[:with_disposition])
              .entered_by(filters[:entered_by])
              .containing(filters[:containing])
              .distinct.pluck(:discovery_stage).sort
    else
      raw = [filters[:with_discovery]]
    end
    options = []
    raw.each do |raw_value|
      label = case raw_value
              when "before" then "Before Processing"
              when "during" then "During Processing"
              when "after" then "After Processing"
              end
      options << [label, raw_value]
    end
    return options
  end

  # Get filter options for disposition.
  def self.disposition_options(filters)
    raw = []
    if filters[:with_disposition].blank?
      raw = Report
              .on_or_before(filters[:on_or_before])
              .on_or_after(filters[:on_or_after])
              .with_year(filters[:with_year])
              .with_customer(filters[:with_customer])
              .with_process(filters[:with_process])
              .with_part(filters[:with_part])
              .with_shop_order(filters[:with_shop_order])
              .with_discovery(filters[:with_discovery])
              .with_disposition(filters[:with_disposition])
              .entered_by(filters[:entered_by])
              .containing(filters[:containing])
              .distinct.pluck(:disposition).sort
    else
      raw = [filters[:with_disposition]]
    end
    options = []
    raw.each do |raw_value|
      label = case raw_value
              when "unprocessed" then "Unprocessed"
              when "partial" then "Partially Processed"
              when "complete" then "Completely Processed"
              end
      options << [label, raw_value]
    end
    return options
  end

  # Get filter options for user.
  def self.user_options(filters)
    raw = []
    if filters[:entered_by].blank?
      raw = Report
              .on_or_before(filters[:on_or_before])
              .on_or_after(filters[:on_or_after])
              .with_year(filters[:with_year])
              .with_customer(filters[:with_customer])
              .with_process(filters[:with_process])
              .with_part(filters[:with_part])
              .with_shop_order(filters[:with_shop_order])
              .with_discovery(filters[:with_discovery])
              .with_disposition(filters[:with_disposition])
              .entered_by(filters[:entered_by])
              .containing(filters[:containing])
              .distinct.pluck(:user_id).sort
    else
      raw = [filters[:entered_by]]
    end
    return User.where("id IN (?)", raw).order(:employee_number).map {|u| ["#{u.employee_number} - #{u.name}", u.id]}
  end

end