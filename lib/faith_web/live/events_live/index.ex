defmodule FaithWeb.EventsLive.Index do
  use FaithWeb, :live_view

  alias Faith.Events
  alias Faith.Events.Event
  alias FaithWeb.DisplayHelper

  @impl true
  def render(assigns) do
    ~H"""
    <.link :if={@current_user.admin} patch={~p"/events/new"}>
      <.button class="float-right inline-flex items-center text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">
        New Event
      </.button>
    </.link>
    <Flop.Phoenix.table
      opts={FaithWeb.FlopConfig.table_opts()}
      items={@streams.events}
      meta={@meta}
      path={~p"/events"}
    >
      <:col :let={{_, event}} label="ID"><%= event.index %></:col>
      <:col :let={{_, event}} label="Name" field={:name}><%= event.name %></:col>
      <:col :let={{_, event}} label="Location" field={:location}><%= event.location %></:col>
      <:col :let={{_, event}} label="Description"><%= event.description %></:col>
      <:col :let={{_, event}} label="Start Date" field={:start_date}>
        <%= event.start_date |> DisplayHelper.format_date() %>
      </:col>
      <:action :let={{id, event}}>
        <%= if Enum.all?(@event_invitations, &(&1.event_id != event.id)) do %>
          <.link
            class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
            patch={~p"/events/#{event.id}/invite_matches"}
          >
            Invite
          </.link>
        <% else %>
          <span class="text-gray-400">Already Invited!</span>
        <% end %>
        <.link
          :if={@current_user.admin}
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          patch={~p"/events/#{event.id}/edit"}
        >
          Edit
        </.link>
        <.link
          :if={@current_user.admin}
          class="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-700 focus:outline-none dark:focus:ring-red-800"
          phx-click={
            JS.push("delete", value: %{id: event.id})
            |> hide("##{id}")
          }
          data-confirm="Are you sure?"
        >
          Remove
        </.link>
      </:action>
    </Flop.Phoenix.table>

    <div class="flex justify-center">
      <Flop.Phoenix.pagination
        opts={FaithWeb.FlopConfig.pagination_opts()}
        meta={@meta}
        path={~p"/events"}
      />
    </div>
    <.modal
      :if={@live_action in [:new, :edit]}
      id="event-modal"
      show
      on_cancel={JS.patch(~p"/events")}
    >
      <.live_component
        module={FaithWeb.EventsLive.FormComponent}
        id={@event.id || :new}
        title={@page_title}
        action={@live_action}
        event={@event}
        current_user={@current_user}
        patch={~p"/events"}
      />
    </.modal>
    <.modal
      :if={@live_action == :invite_matches}
      id="event_invitations-modal"
      show
      on_cancel={JS.patch(~p"/events")}
    >
      <.live_component
        module={FaithWeb.EventsLive.InvitationComponent}
        id={@event.id || :new}
        action={@live_action}
        event={@event}
        current_user={@current_user}
        patch={~p"/events"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    %{events: events, meta: meta} = Events.list_events(params)

    events = events |> Enum.with_index(1) |> Enum.map(fn {u, i} -> Map.put(u, :index, i) end)

    event_invitations =
      (Events.list_sent_event_invitations_for_user(socket.assigns.current_user.id)
       |> Enum.reject(&(&1.status == :declined))) ++
        Events.list_accepted_event_invitations_for_user(socket.assigns.current_user.id)

    {:ok,
     socket
     |> assign(:current_page, :events)
     |> assign(:page_title, "Events")
     |> stream(:events, events, reset: true)
     |> assign(:meta, meta)
     |> assign(:event_invitations, event_invitations)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => event_id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Events.get_event!(event_id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :invite_matches, %{"id" => event_id}) do
    socket
    |> assign(:page_title, "Invite Matches")
    |> assign(:event, Events.get_event!(event_id))
  end

  defp apply_action(socket, _, _params) do
    socket
  end

  @impl true
  def handle_info({FaithWeb.EventsLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  def handle_info({FaithWeb.EventsLive.InvitationComponent, {:saved, event_invitation}}, socket) do
    event_invitations = [event_invitation | socket.assigns.event_invitations]

    {:noreply, assign(socket, :event_invitations, event_invitations)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply,
     stream_delete(socket, :events, event)
     |> put_flash(:info, "Event deleted successfully")}
  end
end
