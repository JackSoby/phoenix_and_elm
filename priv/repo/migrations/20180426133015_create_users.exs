defmodule PhoenixAndElm.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :state, :string
      add :city, :string

      timestamps()
    end

  end
end
