# frozen_string_literal: true

module VisitsHelper
  def quick_filter_link(label, range, current_range, path)
    is_active = range[:start_date] == current_range[:start_date] && range[:end_date] == current_range[:end_date]
    # TODO: Maybe remove rounded-md because it looks weird in the middle, but how would this look if its the end?
    if is_active
      content_tag(:span, label,
                  class: "px-4 py-2 bg-indigo-100 text-indigo-600 font-medium cursor-not-allowed rounded-md")
    else
      link_to(label, path, class: "px-4 py-2 text-indigo-500 hover:bg-gray-100 focus:outline-none")
    end
  end
end
