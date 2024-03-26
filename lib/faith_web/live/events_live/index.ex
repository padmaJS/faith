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
    <.table id="events" rows={@streams.events}>
      <:col :let={{_, event}} label="ID"><%= event.index %></:col>
      <:col :let={{_, event}} label="Name"><%= event.name %></:col>
      <:col :let={{_, event}} label="Location"><%= event.location %></:col>
      <:col :let={{_, event}} label="Description"><%= event.description %></:col>
      <:col :let={{_, event}} label="Start Date">
        <%= event.start_date |> DisplayHelper.format_date() %>
      </:col>
      <:action :let={{id, event}} :if={@current_user.admin}>
        <.link
          class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          patch={~p"/events/#{event.id}/edit"}
        >
          Edit
        </.link>
        <.link
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
    </.table>
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
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    events = Events.list_events() |> Enum.with_index(&Map.put(&1, :index, &2 + 1))

    {:ok, stream(socket, :events, events) |> assign(:current_page, :events)}
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

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Events")
  end

  @impl true
  def handle_info({FaithWeb.EventsLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
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
