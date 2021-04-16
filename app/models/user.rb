class User < ApplicationRecord
  
  # Configure Devise for authentication.
  devise  :rememberable,
          :trackable,
          :timeoutable,
          :omniauthable, omniauth_providers: [:google_oauth2]

  # Scopes.
  scope :by_number, -> { order(:employee_number) }
        
  # Validations.
  validates :email, :name, :employee_number,
            presence: true
  validates :email, :employee_number,
            uniqueness: true
  validates :email,
            format: { with: /@varland.com\z/ }
  validates :employee_number,
            numericality: { only_integer: true, greater_than: 0 }

  # Class methods.

  # Method to create from Google authentication.
  def self.from_google(email:, name:, uid:)
    system_i = self.system_i_json(email)
    return nil if system_i.blank? || !system_i[:is_valid]
    user_attributes = {
      uid: uid,
      name: name,
      employee_number: system_i[:employee_number]
    }
    create_with(user_attributes).find_or_create_by!(email: email)
  end

  # Method to lookup user information from System i.
  def self.system_i_json(email)
    uri = URI.parse("http://json400.varland.com/validate_employee?email=#{email}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    return nil unless response.code.to_s == "200"
    return JSON.parse(response.body, symbolize_names: true)
  end

end