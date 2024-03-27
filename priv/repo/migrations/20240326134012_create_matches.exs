defmodule Faith.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_1_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :user_2_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create unique_index(:matches, [:user_1_id, :user_2_id])
  end
end
