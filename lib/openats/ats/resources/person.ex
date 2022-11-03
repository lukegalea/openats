defmodule Openats.Ats.Person do
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
    table "people"
    repo Openats.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end
  end

  relationships do
    has_many :candidates, Openats.Ats.Candidate
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  json_api do
    type "people"
    routes do
      base "/people"
      get :read
      index :read
    end
  end

  pub_sub do
    prefix "person"

    module(OpenatsWeb.Endpoint)

    publish(:create, ["created", :id])
    publish_all :create, "created"
  end
end
