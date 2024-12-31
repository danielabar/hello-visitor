# frozen_string_literal: true

module VisitsHelper
  def quick_filter_link(label, range, current_range, path)
    is_active = range[:start_date] == current_range[:start_date] && range[:end_date] == current_range[:end_date]
    if is_active
      content_tag(:span, label,
                  class: "px-4 py-2 bg-indigo-100 text-indigo-600 font-medium cursor-not-allowed rounded-md",
                  data: { test_id: "quick-filter-active", label: label })
    else
      link_to(label, path, class: "px-4 py-2 text-indigo-500 hover:bg-gray-100 focus:outline-none",
                           data: { test_id: "quick-filter-link", label: label })
    end
  end
end
