defmodule Faith.Matches.Swipe do
  use Faith.Schema
  import Ecto.Changeset

  schema "swipes" do
    field :direction, :string

    belongs_to :receiver, Faith.Accounts.User
    belongs_to :sender, Faith.Accounts.User

    timestamps()
  end

  def changeset(swipe, attrs) do
    swipe
    |> cast(attrs, [:direction, :receiver_id, :sender_id])
    |> validate_required([:direction, :receiver_id, :sender_id])
    |> unique_constraint([:receiver_id, :sender_id])
  end
end
