# frozen_string_literal: true

module VisitsHelper
  def granularity_link(label, value, visit_search)
    is_active = visit_search.granularity == value
    search_params = {
      granularity: value,
      start_date: visit_search.start_date,
      end_date: visit_search.end_date,
      url: visit_search.url,
      referrer: visit_search.referrer
    }
    path = visits_path(visit_search: search_params)

    if is_active
      content_tag(:span, label,
                  class: "px-4 py-2 bg-indigo-100 text-indigo-600 font-medium cursor-not-allowed",
                  data: { test_id: "granularity-active", label: label })
    else
      link_to(label, path, class: "px-4 py-2 text-indigo-500 hover:bg-gray-100 focus:outline-none",
                           data: { test_id: "granularity-link", label: label })
    end
  end

  def quick_filter_link(label, range, current_range, path)
    is_active = range[:start_date] == current_range[:start_date] && range[:end_date] == current_range[:end_date]
    if is_active
      content_tag(:span, label,
                  class: "px-4 py-2 bg-indigo-100 text-indigo-600 font-medium cursor-not-allowed",
                  data: { test_id: "quick-filter-active", label: label })
    else
      link_to(label, path, class: "px-4 py-2 text-indigo-500 hover:bg-gray-100 focus:outline-none",
                           data: { test_id: "quick-filter-link", label: label })
    end
  end
end
