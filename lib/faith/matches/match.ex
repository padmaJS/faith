defmodule Faith.Matches.Match do
  use Faith.Schema
  import Ecto.Changeset

  schema "matches" do
    belongs_to :user_1, Faith.Accounts.User
    belongs_to :user_2, Faith.Accounts.User

    timestamps()
  end

  def changeset(match, attrs) do
    match
    |> cast(attrs, [:user_1_id, :user_2_id])
    |> validate_required([:user_1_id, :user_2_id])
    |> unique_constraint([:user_1_id, :user_2_id])
  end
end
