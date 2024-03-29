defmodule FaithWeb.Router do
  use FaithWeb, :router

  import FaithWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FaithWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", FaithWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:faith, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FaithWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", FaithWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{FaithWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", FaithWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session(:require_authenticated_admin,
      on_mount: [{FaithWeb.UserAuth, :ensure_authenticated}, {FaithWeb.Auth, :admin}]
    ) do
      live "/events/new", EventsLive.Index, :new
      live "/events/:id/edit", EventsLive.Index, :edit
      live "/events/:id/invite_matches", EventsLive.Index, :invite_matches

      scope "/admin", Admin do
        live "/users", UsersLive.Index, :index

        live "/reported_users", ReportedUsersLive.Index, :index
      end
    end
  end

  scope "/", FaithWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{FaithWeb.UserAuth, :ensure_authenticated}] do
      live "/", DashboardLive.Index, :index
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/users/profile/:user_id", UserProfileLive.Show, :show
      live "/users/profile/:user_id/report_user", UserProfileLive.Show, :report_user

      live "/events", EventsLive.Index, :index

      live "/discover", DiscoverLive.Index, :index

      live "/messages", MessagesLive.Index, :index
      live "/messages/:id/chat", MessagesLive.Index, :chat
    end
  end

  scope "/", FaithWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{FaithWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
