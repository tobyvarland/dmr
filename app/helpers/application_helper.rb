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
      label = content_tag(:div, "#{item[:label]}:", class: ["w-33", "text-uncolor", "text-small-baseline", "text-nowrap"])
      value = content_tag(:div, item[:value].html_safe)
      list_items << content_tag(:li, label + value, class: ["list-group-item", "d-flex", "flex-row", "align-items-top", "justify-content-start", "bg-light"])
    end
    header = content_tag(:h6, title, class: ["card-header"])
    list = content_tag(:ul, list_items.join.html_safe, class: ["list-group", "list-group-flush"])
    content_tag(:div, header + list, class: ["card", "bg-light", "mb-3"])
  end

end