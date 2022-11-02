defmodule Openats.Ats.PositionOpening do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "postion_openings"
    repo Openats.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :status, :atom do
      constraints [one_of: [:active, :closed, :incomplete]]
      default :active
      allow_nil? false
    end
  end

  actions do
    create :open do
      accept [:name]
    end

    update :close do
      accept []

      change set_attribute(:status, :closed)
    end
  end

  json_api do
    type "position_openings"
    routes do
      base "/position_openings"
      # Add a `GET /position_openings/:id` route, that calls into the :read action called :read
      get :read
      # Add a `GET /position_openings` route, that calls into the :read action called :read
      index :read
    end
  end
end
