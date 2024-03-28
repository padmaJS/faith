defmodule Faith.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Faith.Repo

  alias Faith.Events.{Event, EventInvitation}

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  def list_events(params) do
    case Flop.validate_and_run(Event, params, for: Event) do
      {:ok, {events, meta}} ->
        %{events: events, meta: meta}

      {:error, meta} ->
        %{events: [], meta: meta}
    end
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  def change_event_invitation(%EventInvitation{} = event_invitation, attrs \\ %{}) do
    EventInvitation.changeset(event_invitation, attrs)
  end

  def create_event_invitation(attrs \\ %{}) do
    %EventInvitation{}
    |> EventInvitation.changeset(attrs)
    |> Repo.insert()
  end

  def get_event_invitation!(id), do: Repo.get!(EventInvitation, id)

  def get_sent_event_invitation(user_id, event_id) do
    EventInvitation
    |> where([ei], ei.sender_id == ^user_id and ei.event_id == ^event_id)
    |> Repo.one()
  end

  def list_received_event_invitations_for_event_and_user(event_id, user_id) do
    EventInvitation
    |> where(
      [ei],
      ei.receiver_id == ^user_id and ei.event_id == ^event_id and ei.status == :requested
    )
    |> Repo.all()
    |> Repo.preload([:sender])
  end

  def list_sent_event_invitations_for_user(user_id) do
    EventInvitation
    |> where([ei], ei.sender_id == ^user_id)
    |> Repo.all()
  end

  def list_accepted_event_invitations_for_user(user_id) do
    EventInvitation
    |> where([ei], ei.receiver_id == ^user_id and ei.status == :going)
    |> Repo.all()
  end

  def accept_invitation(event_invitation_id) do
    get_event_invitation!(event_invitation_id)
    |> Ecto.Changeset.change(%{status: :going})
    |> Repo.update()
  end

  def decline_invitation(event_invitation_id) do
    get_event_invitation!(event_invitation_id)
    |> Ecto.Changeset.change(%{status: :declined})
    |> Repo.update()
  end
end
