module ApplicationHelper

  # Load Pagy front end components.
  include Pagy::Frontend

  def discovery_label(k)
    text = nil
    case k
    when "before"
      text = "Before Processing"
    when "during"
      text = "During Processing"
    when "after"
      text = "After Processing"
    end
    content_tag(:span, text, class: "badge bg-secondary")
  end

  def disposition_label(k)
    text = nil
    case k
    when "unprocessed"
      text = "Unprocessed"
    when "partial"
      text = "Partially Processed"
    when "complete"
      text = "Completely Processed"
    end
    content_tag(:span, text, class: "badge bg-secondary")
  end

  def card_list(title, items)
    list_items = []
    items.each do |item|
      label = content_tag(:div, "#{item[:label]}:", class: ["text-uncolor", "small", "text-nowrap", "lh-1"])
      value = content_tag(:div, item[:value].html_safe, class: ["lh-sm", "my-0"])
      list_items << content_tag(:li, label + value, class: ["list-group-item", "d-flex", "flex-column", "align-items-top", "justify-content-start", "bg-light"])
    end
    header = content_tag(:h6, title, class: ["card-header"])
    list = content_tag(:ul, list_items.join.html_safe, class: ["list-group", "list-group-flush"])
    content_tag(:div, header + list, class: ["card", "bg-light", "mb-3"])
  end

  # Return options for given field for collection of reports.
  def field_options(reports, field)
    return reports.except(:limit, :offset, :order).distinct.pluck(field).sort
  end

  # Return discovery stage options for collection of reports.
  def discovery_options(reports)
    raw = field_options(reports, :discovery_stage)
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

  # Return disposition options for collection of reports.
  def disposition_options(reports)
    raw = field_options(reports, :disposition)
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

  # Return user options for collection of reports.
  def user_options(reports)
    return User.where("id IN (?)", field_options(reports, :user_id)).order(:employee_number).map {|u| ["#{u.employee_number} - #{u.name}", u.id]}
  end

end