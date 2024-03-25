defmodule Faith.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :full_name, :string
      add :email, :citext, null: false
      add :admin, :boolean, default: false, null: false
      add :location, :string
      add :gender, :string
      add :profile_image, :string
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime
      add :date_of_birth, :date
      add :description, :text
      add :occupation, :string
      add :education, :string
      add :interests, :text
      add :denomination, :string
      add :preferred_min_age, :integer
      add :looking_for, :string
      add :completed_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    create table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
