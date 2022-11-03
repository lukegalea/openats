defmodule Openats.Ats.PositionProfile do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [
      Ash.Notifier.PubSub
    ],
    extensions: [
      AshJsonApi.Resource,
      AshAdmin.Resource
    ]

  postgres do
    table "position_openings"
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

    attribute :description, :string do
      allow_nil? false
    end

    attribute :qualifications, {:array, :string}
  end

  relationships do
    has_many :position_openings, Openats.Ats.PositionOpening
  end

  json_api do
    type "position_profiles"
    routes do
      base "/position_profiles"
      get :read
      index :read
    end
  end

  pub_sub do
    prefix "position_profile"

    module(OpenatsWeb.Endpoint)

    publish(:create, ["created", :id])
    publish_all :create, "created"
  end

  # admin do
  #   form do
  #     field
  #   end
  # end
end
