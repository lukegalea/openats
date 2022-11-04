defmodule Openats.Repo.Migrations.AddUserIdToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :user_id, :int
    end
  end
end
