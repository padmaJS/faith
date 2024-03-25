defmodule FaithWeb.DashboardLive.Index do
  use FaithWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    Page under construction
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :dashboard)}
  end
end
