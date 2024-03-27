defmodule Faith.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :sender_id, references(:users, type: :binary_id, on_delete: :nothing)
      add :receiver_id, references(:users, type: :binary_id, on_delete: :nothing)
      timestamps()
    end

    create index(:messages, [:sender_id, :receiver_id])
  end
end
