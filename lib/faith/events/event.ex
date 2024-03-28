defmodule Faith.Events.Event do
  use Faith.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:name, :location, :start_date], sortable: [:name, :location, :start_date]
  }

  schema "events" do
    field :name, :string
    field :description, :string
    field :location, :string
    field :start_date, :utc_datetime

    has_many :event_invitations, Faith.Events.EventInvitation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :description, :start_date, :location])
    |> validate_required([:name, :description, :start_date, :location])
  end
end
