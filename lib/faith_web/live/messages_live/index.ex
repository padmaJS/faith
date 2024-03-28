defmodule FaithWeb.MessagesLive.Index do
  use FaithWeb, :live_view

  alias Faith.Matches
  alias Faith.Matches.Message

  def render(assigns) do
    ~H"""
    <div class="flex h-[93vh]">
      <div class="w-[15%] bg-gray-100 px-4">
        <h2 class="font-bold text-xl mb-4 pt-6 pb-1">Matches</h2>
        <div class="space-y-2">
          <%= if @matches == [] do %>
            <span class="text-gray-500">No matches yet</span>
          <% else %>
            <%= for match <- @matches do %>
              <% user = Matches.get_matched_user(match, @current_user.id) %>
              <.link
                class={[
                  "flex items-center hover:bg-gray-200 p-2 rounded-md cursor-pointer w-full",
                  @matched_user && @matched_user.id == user.id && "bg-gray-200"
                ]}
                patch={~p"/messages/#{match.id}/chat"}
              >
                <img
                  src={user.profile_image || ~p"/images/avatar-default.svg"}
                  alt={user.full_name}
                  class="w-10 h-10 rounded-full mr-2"
                />
                <span class="font-medium"><%= user.full_name %></span>
              </.link>
            <% end %>
          <% end %>
        </div>
      </div>

      <%= if @live_action == :chat && @matched_user do %>
        <div class="bg-white flex flex-col justify-between w-[85%]">
          <div class="flex items-center w-full bg-gray-100 py-2">
            <.link
              navigate={~p"/users/profile/#{@matched_user.id}"}
              phx-click="view_profile"
              class="px-4 py-2 hover:bg-gray-200"
            >
              <div class="flex items-center">
                <img
                  src={@matched_user.profile_image || ~p"/images/avatar-default.svg"}
                  class="w-10 h-10 rounded-full mr-2"
                />
                <%= @matched_user.full_name %>
              </div>
            </.link>
          </div>
          <div class="flex-grow flex flex-col p-4 pb-0 h-[70%]">
            <div class="flex-grow overflow-y-auto">
              <%= for {id, message} <- @streams.messages do %>
                <%= if message.sender_id == @current_user.id do %>
                  <div id={id} class="flex justify-end mb-4 items-center">
                    <div class="bg-blue-500 rounded-lg p-2 text-wrap">
                      <p class="text-white"><%= message.content %></p>
                    </div>
                    <img
                      src={@current_user.profile_image || ~p"/images/avatar-default.svg"}
                      class="w-6 h-6 rounded-full mx-2"
                    />
                  </div>
                <% else %>
                  <div id={id} class="flex justify-start mb-4 items-center">
                    <img
                      src={@matched_user.profile_image || ~p"/images/avatar-default.svg"}
                      class="w-6 h-6 rounded-full mx-2"
                    />
                    <div class="bg-gray-200 rounded-lg p-2 text-wrap ">
                      <p class="text-gray-800"><%= message.content %></p>
                    </div>
                  </div>
                <% end %>
              <% end %>
            </div>
            <div>
              <.form for={@form} phx-submit="send_message" class="flex">
                <div class="flex-grow">
                  <.input
                    field={@form[:content]}
                    type="text"
                    rows="1"
                    placeholder="Type your message..."
                  />
                </div>
                <button class="bg-blue-500 text-white rounded-lg px-4 py-2 mt-2" type="submit">
                  Send
                </button>
              </.form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    matches = Matches.list_matches_for_user(socket.assigns.current_user.id)
    changeset = Matches.change_message(%Message{})

    {:ok,
     socket
     |> assign(matches: matches, matched_user: nil, current_page: :messages)
     |> assign_form(changeset)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :chat, %{"id" => id}) do
    if connected?(socket), do: FaithWeb.Endpoint.subscribe("chat:#{id}")

    match = Matches.get_match(id)

    messages = Matches.get_messages_for_match(match)

    matched_user = Matches.get_matched_user(match, socket.assigns.current_user.id)

    socket
    |> assign(:match, match)
    |> assign(:matched_user, matched_user)
    |> stream(:messages, messages)
  end

  defp apply_action(socket, _, _params) do
    socket
  end

  def handle_event("send_message", %{"message" => %{"content" => content}}, socket) do
    matched_user = Matches.get_matched_user(socket.assigns.match, socket.assigns.current_user.id)

    {:ok, message} =
      Matches.create_message(%{
        content: content,
        sender_id: socket.assigns.current_user.id,
        receiver_id: matched_user.id
      })

    FaithWeb.Endpoint.broadcast("chat:#{socket.assigns.match.id}", "new_message", %{
      message: message
    })

    changeset = Matches.change_message(%Message{content: ""})

    {:noreply, socket |> assign_form(changeset)}
  end

  def handle_info(%{event: "new_message", payload: %{message: _message}}, socket) do
    messages = Matches.get_messages_for_match(socket.assigns.match)

    {:noreply, socket |> stream(:messages, messages)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
