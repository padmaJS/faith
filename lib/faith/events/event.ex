defmodule Faith.Events.Event do
  use Faith.Schema
  import Ecto.Changeset

  schema "events" do
    field :description, :string
    field :location, :string
    field :name, :string
    field :start_date, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :description, :start_date, :location])
    |> validate_required([:name, :description, :start_date, :location])
  end
end
