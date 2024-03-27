defmodule Faith.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Faith.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        location: "some location",
        name: "some name",
        start_date: ~U[2024-03-25 04:26:00Z]
      })
      |> Faith.Events.create_event()

    event
  end
end
