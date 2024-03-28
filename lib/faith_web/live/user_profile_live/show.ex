defmodule FaithWeb.UserProfileLive.Show do
  use FaithWeb, :live_view

  alias Faith.Accounts
  alias Faith.Accounts.ReportUser

  def render(assigns) do
    ~H"""
    <div class="container mx-auto py-8 px-4 bg-gray-100 shadow-lg rounded-lg">
      <div class="flex flex-col md:flex-row md:space-x-8">
        <.link
          patch={~p"/users/profile/#{@user.id}/report_user"}
          class="absolute top-8 right-4 p-[8px] rounded-full bg-gray-200 hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          <svg
            class="h-6 w-6"
            viewBox="0 0 36 36"
            xmlns="http://www.w3.org/2000/svg"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            aria-hidden="true"
            role="img"
            class="iconify iconify--twemoji"
            preserveAspectRatio="xMidYMid meet"
            fill="#000000"
          >
            <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
            <g id="SVGRepo_iconCarrier">
              <path
                fill="#ff4d4d"
                d="M2.653 35C.811 35-.001 33.662.847 32.027L16.456 1.972c.849-1.635 2.238-1.635 3.087 0l15.609 30.056c.85 1.634.037 2.972-1.805 2.972H2.653z"
              >
              </path>
              <path
                fill="#e0e0e0"
                d="M15.583 28.953a2.421 2.421 0 0 1 2.419-2.418a2.421 2.421 0 0 1 2.418 2.418a2.422 2.422 0 0 1-2.418 2.419a2.422 2.422 0 0 1-2.419-2.419zm.186-18.293c0-1.302.961-2.108 2.232-2.108c1.241 0 2.233.837 2.233 2.108v11.938c0 1.271-.992 2.108-2.233 2.108c-1.271 0-2.232-.807-2.232-2.108V10.66z"
              >
              </path>
            </g>
          </svg>
        </.link>
        <div class="flex flex-col space-y-4 items-center justify-center md:w-1/2">
          <img
            class="w-40 h-40 rounded-full object-cover mx-auto"
            src={@user.profile_image || "/images/avatar-default.png"}
            alt="Profile Picture"
          />
          <h2 class="text-2xl font-bold text-center md:text-left"><%= @user.full_name %></h2>
          <p class="text-gray-600 text-center md:text-left"><%= @user.description %></p>
        </div>
        <div class="flex-grow flex flex-col space-y-4 md:w-1/2">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Email:</p>
              <p><%= @user.email %></p>
            </div>
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Gender:</p>
              <p><%= @user.gender %></p>
            </div>
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Date of Birth:</p>
              <p><%= @user.date_of_birth %></p>
            </div>
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Occupation:</p>
              <p><%= @user.occupation %></p>
            </div>
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Education:</p>
              <p><%= @user.education %></p>
            </div>
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Interests:</p>
              <p><%= @user.interests %></p>
            </div>
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Denomination:</p>
              <p><%= @user.denomination %></p>
            </div>
            <div class="flex flex-col space-y-2">
              <p class="text-gray-700 font-medium">Looking for:</p>
              <p><%= @user.looking_for %></p>
            </div>
          </div>
          <div>
            <p class="text-gray-700 font-medium">Location:</p>
            <p class="text-gray-600"><%= @user.location %></p>
          </div>
        </div>
      </div>
    </div>
    <.modal
      :if={@live_action == :report_user}
      id="report_user-modal"
      show
      on_cancel={JS.patch(~p"/users/profile/#{@user.id}")}
    >
      <.live_component
        module={FaithWeb.UserProfileLive.ReportComponent}
        id={@user.id || :new}
        title={"Report #{@user.full_name}"}
        action={@live_action}
        user={@user}
        current_user={@current_user}
        report_user={@report_user}
        patch={~p"/users/profile/#{@user.id}"}
      />
    </.modal>
    """
  end

  def mount(_, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    assign(socket, user: user, report_user: nil)
  end

  defp apply_action(socket, :report_user, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    assign(socket, user: user, report_user: %ReportUser{})
  end
end
