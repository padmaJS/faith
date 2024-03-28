defmodule Faith.Events.EventInvitation do
  use Faith.Schema
  import Ecto.Changeset

  schema "event_invitations" do
    field :status, Ecto.Enum, values: [:requested, :going, :declined], default: :requested

    belongs_to :event, Faith.Events.Event
    belongs_to :sender, Faith.Accounts.User
    belongs_to :receiver, Faith.Accounts.User

    timestamps()
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:status, :event_id, :sender_id, :receiver_id])
    |> validate_required([:event_id, :sender_id, :receiver_id])
  end
end
