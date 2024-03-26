defmodule Faith.Matches do
  import Ecto.Query, warn: false

  alias Faith.Repo
  alias Faith.Matches.{Swipe, Match}

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
end
