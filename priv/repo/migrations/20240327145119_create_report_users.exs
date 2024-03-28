defmodule Faith.Repo.Migrations.CreateReportUsers do
  use Ecto.Migration

  def change do
    create table(:report_users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :sender_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :receiver_id, references(:users, on_delete: :nothing, type: :binary_id)

      add :reason, :string

      timestamps()
    end
  end
end
