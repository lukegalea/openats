defmodule Openats.Ats.PositionOpening do
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
    table "postion_openings"
    repo Openats.Repo
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

  relationships do
    belongs_to :position_profile, Openats.Ats.PositionProfile
  end

  actions do
    defaults [:read, :update, :destroy]

    create :open do
      accept [:name]

      argument :position_profile_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:position_profile_id, :position_profile, type: :append_and_remove)
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
      get :read
      index :read
    end
  end

  pub_sub do
    prefix "position_opening"

    module(OpenatsWeb.Endpoint)

    publish(:create, ["created", :id])
    publish_all :create, "created"
  end

  # admin do
  #   form do
  #     field :name, type: :default
  #   end
  # end
end
