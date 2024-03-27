defmodule FaithWeb.DiscoverLive.Index do
  use FaithWeb, :live_view

  alias Faith.Matches

  def render(assigns) do
    ~H"""
    <%= if @user do %>
      <div class="w-full max-w-sm bg-white border border-gray-200 rounded-lg shadow-2xl dark:bg-gray-800 dark:border-gray-700 mx-auto h-[450px]">
        <div class="flex flex-col items-center pb-10 pt-5 justify-between h-full">
          <img
            class="w-[150px] h-[150px] mb-3 rounded-full shadow-lg"
            src={@user.profile_image || ~p"/images/avatar-default.svg"}
          />
          <h5 class="mb-1 text-xl font-medium text-gray-900 dark:text-white">
            <%= @user.full_name %>
          </h5>
          <span class="text-sm text-gray-500 dark:text-gray-400 px-6"><%= @user.description %></span>
          <div class="w-full flex mt-4 md:mt-6 justify-around">
            <button phx-click="left_swipe" phx-value-receiver_id={@user.id}>
              <svg
                class="w-11 h-11"
                viewBox="0 0 60 60"
                xmlns="http://www.w3.org/2000/svg"
                fill="#000000"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <defs>
                    <style>
                      .cls-2 { fill: #9f4c4c; fill-rule: evenodd; }
                    </style>
                  </defs>
                  <path
                    class="cls-2"
                    d="M100,390a30,30,0,1,1,30-30A30,30,0,0,1,100,390Zm18-30a4,4,0,0,1-4,4H86a4,4,0,0,1,0-8h28A4,4,0,0,1,118,360Z"
                    id="remove"
                    transform="translate(-70 -330)"
                  >
                  </path>
                </g>
              </svg>
            </button>
            <button phx-click="right_swipe" phx-value-receiver_id={@user.id}>
              <svg
                class="w-11 h-11"
                viewBox="0 0 60 60"
                xmlns="http://www.w3.org/2000/svg"
                fill="#000000"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <defs>
                    <style>
                      .cls-1 { fill: #699f4c; fill-rule: evenodd; }
                    </style>
                  </defs>
                  <path
                    class="cls-1"
                    d="M800,510a30,30,0,1,1,30-30A30,30,0,0,1,800,510Zm-16.986-23.235a3.484,3.484,0,0,1,0-4.9l1.766-1.756a3.185,3.185,0,0,1,4.574.051l3.12,3.237a1.592,1.592,0,0,0,2.311,0l15.9-16.39a3.187,3.187,0,0,1,4.6-.027L817,468.714a3.482,3.482,0,0,1,0,4.846l-21.109,21.451a3.185,3.185,0,0,1-4.552.03Z"
                    id="check"
                    transform="translate(-770 -450)"
                  >
                  </path>
                </g>
              </svg>
            </button>
          </div>
        </div>
      </div>
    <% else %>
      Whoops. No users found.
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    user =
      Matches.list_users_without_matching_swipe(socket.assigns.current_user.id) |> Enum.at(0)

    {:ok, assign(socket, user: user, current_page: :discover)}
  end

  def handle_event("left_swipe", %{"receiver_id" => receiver_id}, socket) do
    Matches.create_swipe(%{
      sender_id: socket.assigns.current_user.id,
      receiver_id: receiver_id,
      direction: "left"
    })

    user =
      Matches.list_users_without_matching_swipe(socket.assigns.current_user.id) |> Enum.at(0)

    {:noreply, socket |> assign(user: user)}
  end

  def handle_event("right_swipe", %{"receiver_id" => receiver_id}, socket) do
    case Matches.create_swipe(%{
           sender_id: socket.assigns.current_user.id,
           receiver_id: receiver_id,
           direction: "right"
         }) do
      {:ok, _} ->
        user =
          Matches.list_users_without_matching_swipe(socket.assigns.current_user.id) |> Enum.at(0)

        socket =
          case Matches.maybe_create_match(%{
                 user_1_id: socket.assigns.current_user.id,
                 user_2_id: receiver_id
               }) do
            {:ok, _} ->
              socket |> put_flash(:info, "Match found!")

            _ ->
              socket
          end

        {:noreply, socket |> assign(user: user)}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Error. Please try again.")}
    end
  end
end
