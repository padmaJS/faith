defmodule Faith.Matches do
  import Ecto.Query, warn: false

  alias Faith.Repo
  alias Faith.Accounts.User
  alias Faith.Matches.{Swipe, Match, Message}

  def create_swipe(attrs \\ %{}) do
    %Swipe{}
    |> Swipe.changeset(attrs)
    |> Repo.insert()
  end

  def get_swipe(id) do
    Repo.get(Swipe, id)
  end

  def delete_swipe(%Swipe{} = swipe) do
    Repo.delete(swipe)
  end

  def get_user_swipes(user_id) do
    Repo.all(from s in Swipe, where: s.sender_id == ^user_id or s.receiver_id == ^user_id)
  end

  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  def maybe_create_match(%{user_1_id: user_1_id, user_2_id: user_2_id} = params) do
    if get_mutual_swipe(user_1_id, user_2_id) do
      create_match(params)
    end
  end

  def get_mutual_swipe(user_1_id, user_2_id) do
    Swipe
    |> where([s], s.sender_id == ^user_1_id and s.receiver_id == ^user_2_id)
    |> join(:inner, [s], s2 in Swipe,
      on: s.receiver_id == s2.sender_id and s.sender_id == s2.receiver_id
    )
    |> select([s, s2], s)
    |> Repo.one()
  end

  def get_match(id) do
    Repo.get(Match, id)
  end

  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  def list_users_without_matching_swipe(user_id) do
    User
    |> where(
      [u],
      u.id != ^user_id and
        u.id not in subquery(
          Swipe
          |> where([s], s.sender_id == ^user_id)
          |> select([s], s.receiver_id)
        )
    )
    |> Repo.all()
  end

  def list_matches_for_user(user_id) do
    Match
    |> where([m], m.user_1_id == ^user_id or m.user_2_id == ^user_id)
    |> Repo.all()
    |> Repo.preload([:user_1, :user_2])
  end

  def list_matched_users(user_id) do
    list_matches_for_user(user_id)
    |> Enum.map(&get_matched_user(&1, user_id))
  end

  def get_matched_user(match, user_id) do
    match = Repo.preload(match, [:user_1, :user_2])
    if match.user_1_id != user_id, do: match.user_1, else: match.user_2
  end

  def get_messages_for_match(match) do
    Message
    |> where(
      [m],
      (m.sender_id == ^match.user_1_id and m.receiver_id == ^match.user_2_id) or
        (m.sender_id == ^match.user_2_id and m.receiver_id == ^match.user_1_id)
    )
    |> Repo.all()
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
