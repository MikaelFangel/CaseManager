defmodule CaseManager.Cases.Case do
  @moduledoc """
  Resource that represents a single case in the system.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Cases,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer]

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string

    attribute :status, :string do
      allow_nil? false
      default "In Progress"
    end

    attribute :priority, :string do
      allow_nil? false
    end

    attribute :assignee_id, :uuid

    attribute :team_id, :uuid do
      allow_nil? false
    end

    attribute :escalated, :boolean do
      allow_nil? false
    end

    timestamps()
  end

  resource do
    plural_name :cases
  end

  pub_sub do
    module CaseManagerWeb.Endpoint

    prefix "case"
    publish :create, ["created"]
  end

  postgres do
    table "case"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "case_to_team_fkey"
    end
  end

  validations do
    validate one_of(:status, ["In Progress", "Pending", "Closed", "Benign"])
    validate one_of(:priority, ["Info", "Low", "Medium", "High", "Critical"])
  end

  actions do
    create :create do
      accept [
        :title,
        :description,
        :status,
        :priority,
        :escalated,
        :assignee_id,
        :team_id
      ]

      change fn changeset, _context ->
        changeset
        |> Ash.Changeset.get_attribute(:priority)
        |> case do
          nil ->
            changeset

          priority ->
            Ash.Changeset.change_attribute(changeset, :priority, String.capitalize(priority))
        end
      end
    end

    read :read do
      primary? true
      prepare build(load: [:team])

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    read :get_by_id do
      argument :id, :uuid
      filter expr(id == ^arg(:id))
    end
  end

  code_interface do
    define :get_by_id, action: :get_by_id, args: [:id], get?: true
  end

  policies do
    policy action_type(:create) do
      authorize_if CaseManager.Policies.MSSPCreatePolicy
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team do
      allow_nil? false
    end

    many_to_many :alert, CaseManager.Alerts.Alert do
      through CaseManager.Relationships.CaseAlert
      source_attribute_on_join_resource :case_id
      destination_attribute_on_join_resource :alert_id
    end

    has_many :comment, CaseManager.Cases.Comment
  end
end
