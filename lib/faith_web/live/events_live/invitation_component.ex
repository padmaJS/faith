defmodule FaithWeb.EventsLive.InvitationComponent do
  use FaithWeb, :live_component

  alias Faith.Events
  alias Faith.Matches

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100">
      <div class="container mx-auto p-4">
        <div class="overflow-y-auto max-h-[350px]">
          <div class="grid grid-cols-4 gap-4">
            <div
              :for={invitaion <- @received_invitations}
              class="bg-white rounded-lg shadow-md p-4 text-center"
            >
              <img
                src={invitaion.sender.profile_image || "/images/avatar-default.svg"}
                alt="User Avatar"
                class="w-16 h-16 rounded-full mx-auto mb-2"
              />
              <span class="text-gray-800 font-semibold text-sm">
                <%= invitaion.sender.full_name %>
              </span>
              <button
                phx-target={@myself}
                phx-click="accept_invitation"
                phx-value-invitation_id={invitaion.id}
                class="mt-2 w-[90px] bg-green-500 text-white rounded hover:bg-green-600 focus:outline-none"
              >
                Accept
              </button>
              <button
                phx-target={@myself}
                phx-click="decline_invitation"
                phx-value-invitation_id={invitaion.id}
                class="mt-2 w-[90px] bg-red-500 text-white rounded hover:bg-red-600 focus:outline-none"
              >
                Reject
              </button>
            </div>
            <div :for={user <- @users} class="bg-white rounded-lg shadow-md p-4 text-center">
              <img
                src={user.profile_image || "/images/avatar-default.svg"}
                alt="User Avatar"
                class="w-16 h-16 rounded-full mx-auto mb-2"
              />
              <span class="text-gray-800 font-semibold text-sm"><%= user.full_name %></span>
              <button
                phx-target={@myself}
                phx-click="invite_user"
                phx-value-user_id={user.id}
                class="mt-2 w-[90px] py-1 bg-blue-500 text-white rounded hover:bg-blue-600 focus:outline-none"
              >
                Invite
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    received_invitations =
      Events.list_received_event_invitations_for_event_and_user(
        assigns.event.id,
        assigns.current_user.id
      )

    invitation_senders = received_invitations |> Enum.map(& &1.sender_id)

    users =
      Matches.list_matched_users(assigns.current_user.id)
      |> Enum.reject(&(&1.id in invitation_senders))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(users: users)
     |> assign(received_invitations: received_invitations)}
  end

  def handle_event("invite_user", %{"user_id" => user_id}, socket) do
    case Events.create_event_invitation(%{
           event_id: socket.assigns.event.id,
           receiver_id: user_id,
           sender_id: socket.assigns.current_user.id
         }) do
      {:ok, event_invitation} ->
        notify_parent({:saved, event_invitation})

        {:noreply,
         socket
         |> put_flash(:info, "Invitation sent successfully.")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong.")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  def handle_event("accept_invitation", %{"invitation_id" => invitation_id}, socket) do
    case Events.accept_invitation(invitation_id) do
      {:ok, _event_invitation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation accepted successfully.")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong.")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  def handle_event("decline_invitation", %{"invitation_id" => invitation_id}, socket) do
    case Events.decline_invitation(invitation_id) do
      {:ok, _event_invitation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation declined successfully.")
         |> push_patch(to: socket.assigns.patch)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong.")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
