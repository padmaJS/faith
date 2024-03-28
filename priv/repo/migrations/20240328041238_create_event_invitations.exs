defmodule Faith.Repo.Migrations.CreateEventInvitations do
  use Ecto.Migration

  def change do
    create table(:event_invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :sender_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :receiver_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :status, :string

      timestamps()
    end
  end
end
