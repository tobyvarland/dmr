class ShopOrderValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)

    # Skip if no value given.
    return if value.blank?

    # Look up shop order using System i API.
    uri = URI.parse("http://as400api.varland.com/v1/dmr_shop_order_lookup?shop_order=#{value}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    # If no valid response received, return error.
    unless response.code.to_s == '200'
      record.errors[attribute] << 'lookup failed on the System i'
      return
    end

    # Parse response.
    result = JSON.parse(response.body, symbolize_names: true)

    # If valid, set related attributes. If not valid, add error to record.
    if result[:valid]
      record.customer_code = result[:customer_code]
      record.customer_name = result[:customer_name]
      record.part = result[:part]
      record.part_name = result[:part_name]
      record.pieces = result[:pieces]
      record.pounds = result[:pounds]
      record.process_code = result[:process_code]
      record.purchase_order = result[:purchase_order]
      record.sub = result[:sub]
    else
      record.errors[attribute] << 'was not found on the System i'
    end

  end

end