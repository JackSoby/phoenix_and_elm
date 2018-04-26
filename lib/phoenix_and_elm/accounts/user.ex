defmodule PhoenixAndElm.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :city, :string
    field :email, :string
    field :name, :string
    field :phone, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:city, :email, :name, :phone, :state])
    |> validate_required([:city, :email, :name, :phone, :state])
  end
end
