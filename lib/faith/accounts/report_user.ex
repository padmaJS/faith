defmodule Faith.Accounts.ReportUser do
  use Faith.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:receiver_id], sortable: [:receiver_id]
  }

  schema "report_users" do
    field :reason, :string

    belongs_to :receiver, Faith.Accounts.User
    belongs_to :sender, Faith.Accounts.User

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:reason, :receiver_id, :sender_id])
    |> validate_required([:reason, :receiver_id, :sender_id])
  end
end
