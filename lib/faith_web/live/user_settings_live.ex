defmodule FaithWeb.UserSettingsLive do
  use FaithWeb, :live_view

  alias Faith.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account details</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div>
        <img
          :if={@current_user.profile_image}
          class="w-24 h-24 mb-3 rounded-full shadow-lg"
          src={@current_user.profile_image}
        />

        <.simple_form for={@form} phx-submit="update_profile" phx-change="validate">
          <.live_file_input
            upload={@uploads.profile_image}
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
          />
          <%= for entry <- @uploads.profile_image.entries do %>
            <article class="upload-entry">
              <figure class="flex items-center">
                <.live_img_preview entry={entry} width="150" />
                <figcaption><%= entry.client_name %></figcaption>&nbsp;
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                >
                  &times;
                </button>
              </figure>
            </article>
            <.error :for={err <- upload_errors(@uploads.profile_image, entry)} class="!mt-0">
              <%= error_to_string(err) %>
            </.error>
          <% end %>
          <.error :for={err <- upload_errors(@uploads.profile_image)}>
            <%= error_to_string(err) %>
          </.error>

          <.input field={@form[:full_name]} label="Full Name" type="text" required />

          <.input
            field={@form[:gender]}
            label="Gender"
            type="select"
            options={["male", "female"]}
            prompt="Select your gender"
            required
          />

          <.input field={@form[:date_of_birth]} type="date" label="Birthday" required />

          <.input field={@form[:location]} label="Location" type="text" required />

          <.input field={@form[:description]} label="Description" type="textarea" required />

          <.input field={@form[:occupation]} label="Occupation" type="text" required />

          <.input field={@form[:interests]} label="Interests" type="text" required />

          <.input field={@form[:education]} label="Education" type="text" required />

          <.input
            field={@form[:denomination]}
            label="Denomination"
            type="select"
            options={["catholic", "protestant", "orthodox"]}
            prompt="Select your denomination"
            required
          />

          <.input
            field={@form[:preferred_min_age]}
            label="Preferred Minimum Age"
            type="number"
            required
            min="18"
          />

          <.input
            field={@form[:looking_for]}
            label="Looking for"
            type="select"
            options={["male", "female"]}
            prompt="Who are you looking for"
            required
          />

          <.button type="submit">Save Profile</.button>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    changeset = Accounts.change_user(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign_form(changeset)
      |> assign(:current_page, :profile)
      |> assign(:uploaded_files, [])
      |> allow_upload(:profile_image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1
      )

    {:ok, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :profile_image, ref)}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("update_profile", %{"user" => params}, socket) do
    user = socket.assigns.current_user

    uploaded_files =
      consume_uploaded_entries(socket, :profile_image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:faith), "static", "uploads", Path.basename(path)])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    params =
      if uploaded_files != [],
        do: Map.put(params, "profile_image", List.first(uploaded_files)),
        else: params

    case Accounts.update_user(user, params) do
      {:ok, user} ->
        if !user.completed_at, do: Accounts.mark_completed(user)
        {:noreply, socket |> put_flash(:info, "Profile updated successfully")}

      {:error, changeset} ->
        {:noreply,
         assign(socket, :form, to_form(changeset)) |> put_flash(:error, "Error updating profile")}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
