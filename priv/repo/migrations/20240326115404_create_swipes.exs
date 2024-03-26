defmodule Faith.Repo.Migrations.CreateSwipes do
  use Ecto.Migration

  def change do
    create table(:swipes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :sender_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :receiver_id, references(:users, on_delete: :nothing, type: :binary_id)

      add :direction, :string

      timestamps()
    end

    create unique_index(:swipes, [:sender_id, :receiver_id])
  end
end
