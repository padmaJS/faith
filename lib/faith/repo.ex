defmodule Faith.Repo do
  use Ecto.Repo,
    otp_app: :faith,
    adapter: Ecto.Adapters.Postgres
end
