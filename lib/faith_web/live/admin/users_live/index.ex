defmodule FaithWeb.Admin.UsersLive.Index do
  use FaithWeb, :live_view

  alias Faith.Accounts

  def render(assigns) do
    ~H"""
    <Flop.Phoenix.table
      opts={FaithWeb.FlopConfig.table_opts()}
      items={@streams.users}
      meta={@meta}
      path={~p"/admin/users"}
    >
      <:col :let={{_id, user}} label="">
        <%= user.index %>
      </:col>
      <:col :let={{_id, user}} field={:email} label="Email">
        <%= user.email %>
      </:col>
      <:col :let={{_id, user}} field={:full_name} label="Full Name">
        <%= user.full_name %>
      </:col>
      <:col :let={{_id, user}} label="Gender">
        <%= user.gender %>
      </:col>

      <:action :let={{id, user}}>
        <button
          phx-click="toggle_disable"
          phx-value-user_id={user.id}
          class={[
            "text-white focus:ring-4 font-medium rounded-lg text-sm px-5 py-2 mr-2 mb-2 focus:outline-none",
            user.is_disabled && "!bg-green-700 hover:!bg-green-800 focus:ring-4 focus:ring-green-300",
            !user.is_disabled && "bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300"
          ]}
        >
          <%= if user.is_disabled, do: "Enable", else: "Disable" %>
        </button>
        <.link
          class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800"
          phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
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
        path={~p"/admin/users"}
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
    %{users: users, meta: meta} =
      Accounts.list_users(params)

    users = users |> Enum.with_index(1) |> Enum.map(fn {u, i} -> Map.put(u, :index, i) end)

    socket
    |> stream(:users, users, reset: true)
    |> assign(:current_page, :users)
    |> assign(:meta, meta)
  end

  def handle_event("toggle_disable", %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)

    {:ok, user} =
      Accounts.update_user(user, %{is_disabled: !user.is_disabled, validate_required: false})

    {:noreply, socket |> stream_insert(:users, user)}
  end

  def handle_event("delete", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket |> stream_delete(:users, user)}
  end
end
