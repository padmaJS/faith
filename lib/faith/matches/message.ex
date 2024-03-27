defmodule Faith.Matches.Message do
  use Faith.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string

    belongs_to :sender, Faith.Accounts.User
    belongs_to :receiver, Faith.Accounts.User

    timestamps()
  end

  @attrs [:content, :sender_id, :receiver_id]

  def changeset(message, attrs) do
    message
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
