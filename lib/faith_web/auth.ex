defmodule FaithWeb.Auth do
  use FaithWeb, :verified_routes

  def on_mount(:admin, _params, _session, socket) do
    if admin?(socket.assigns.current_user) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You are not authorized to view this page")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  defp admin?(user), do: user && user.admin
end
