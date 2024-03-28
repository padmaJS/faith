defmodule FaithWeb.Admin.ReportedUsersLive.Index do
  use FaithWeb, :live_view

  alias Faith.Accounts

  def render(assigns) do
    ~H"""
    <Flop.Phoenix.table
      opts={FaithWeb.FlopConfig.table_opts()}
      items={@streams.report_users}
      meta={@meta}
      path={~p"/admin/reported_users"}
    >
      <:col :let={{_id, report_user}} label="">
        <%= report_user.index %>
      </:col>
      <:col :let={{_id, report_user}} field={:email} label="Email">
        <%= report_user.receiver.email %>
      </:col>
      <:col :let={{_id, report_user}} field={:full_name} label="Full Name">
        <%= report_user.receiver.full_name %>
      </:col>
      <:col :let={{_id, report_user}} label="Reason">
        <%= report_user.reason %>
      </:col>

      <:action :let={{id, report_user}}>
        <.link
          class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800"
          phx-click={JS.push("delete", value: %{id: report_user.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </Flop.Phoenix.table>

    <div class="flex justify-center">
      <Flop.Phoenix.pagination
        opts={FaithWeb.FlopConfig.pagination_opts()}
        meta={@meta}
        path={~p"/admin/reported_users"}
      />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _, params) do
    %{report_users: report_users, meta: meta} =
      Accounts.list_report_users(params)

    report_users =
      report_users |> Enum.with_index(1) |> Enum.map(fn {u, i} -> Map.put(u, :index, i) end)

    socket
    |> stream(:report_users, report_users, reset: true)
    |> assign(:current_page, :reported_users)
    |> assign(:meta, meta)
  end

  def handle_event("delete", %{"id" => report_user_id}, socket) do
    report_user = Accounts.get_report_user!(report_user_id)
    {:ok, _report_user} = Accounts.delete_report_user(report_user)

    {:noreply, socket |> stream_delete(:report_users, report_user)}
  end
end
