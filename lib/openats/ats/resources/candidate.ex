defmodule Openats.Ats.Candidate do
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
    table "candidates"
    repo Openats.Repo
  end

  attributes do
    uuid_primary_key :id


    attribute :status, :atom do
      constraints [one_of: [:active, :closed, :incomplete]]
      default :active
      allow_nil? false
    end
  end

  relationships do
    belongs_to :position_opening, Openats.Ats.PositionOpening
    belongs_to :person, Openats.Ats.Person
  end

  actions do
    defaults [:read, :update, :destroy]

    create :apply do
      argument :position_opening_id, :uuid do
        allow_nil? false
      end

      argument :person_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:position_opening_id, :position_opening, type: :append_and_remove)
      change manage_relationship(:person_id, :person, type: :append_and_remove)
      # change set_attribute(:status, :active)
    end

    update :close do
      accept []

      change set_attribute(:status, :closed)
    end
  end

  json_api do
    type "candidates"
    routes do
      base "/candidates"
      get :read
      index :read
    end
  end

  pub_sub do
    prefix "candidate"

    module(OpenatsWeb.Endpoint)

    publish(:create, ["created", :id])
    publish_all :create, "created"
  end
end
