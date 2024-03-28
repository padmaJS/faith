defmodule FaithWeb.UserProfileLive.ReportComponent do
  use FaithWeb, :live_component

  alias Faith.Accounts
  alias Faith.Accounts.ReportUser

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form for={@form} id="event-form" phx-target={@myself} phx-submit="save">
        <.input
          field={@form[:reason]}
          type="select"
          label="Reason"
          options={[
            "Harassment",
            "Hate Speech",
            "Bullying",
            "Impersonation",
            "Unwanted Sexual Content",
            "Suspicious Activity",
            "Fraudulent Profile",
            "Threatening Violence",
            "Spam or Solicitation",
            "Nudity or Pornography",
            "Inappropriate Profile Picture",
            "Underage User",
            "Technical Issues"
          ]}
          prompt="Select a reason"
          required
        />

        <:actions>
          <.button
            class="text-white inline-flex items-center bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
            phx-disable-with="Reporting..."
          >
            Report!
          </.button>
          <.link
            patch={@patch}
            class="text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
          >
            Cancel
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(%ReportUser{} |> Accounts.change_report_user())}
  end

  def handle_event("save", %{"report_user" => report_user_params}, socket) do
    report_user_params =
      report_user_params
      |> Map.put("receiver_id", socket.assigns.user.id)
      |> Map.put("sender_id", socket.assigns.current_user.id)

    case Accounts.create_report_user(report_user_params) do
      {:ok, report_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reported successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
