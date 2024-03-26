defmodule FaithWeb.DisplayHelper do
  use Timex

  def format_date(date_time) do
    Timex.format!(date_time, "%b %e, %Y at %H:%M:%S %p", :strftime)
  end
end
