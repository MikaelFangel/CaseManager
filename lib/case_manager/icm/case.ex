defmodule CaseManager.ICM.Case do
  @moduledoc false
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine, AshAdmin.Resource, AshJsonApi.Resource]

  alias AshStateMachine.Checks.ValidNextState
  alias CaseManager.Changes.SanitizeHtml
  alias CaseManager.ICM.Enums.Status
  alias CaseManager.Teams.User

  @closed_states [:t_positive, :f_positive, :benign]

  postgres do
    table "case"
    repo CaseManager.Repo

    custom_indexes do
      index "title gin_trgm_ops", name: "case_title_gin_index", using: "GIN"
    end

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "case_to_team_fkey"
      reference :reporter, on_delete: :nilify, on_update: :update, name: "case_to_reporter_fkey"
      reference :assignee, on_delete: :nilify, on_update: :update, name: "case_to_assignee_fkey"
    end
  end

  pub_sub do
    module CaseManagerWeb.Endpoint

    prefix "case"
    publish :create, ["created"]
    publish :escalate, ["escalated", "all"]
    publish :escalate, ["escalated", :team_id]
    publish_all :update, ["updated", "all"]
    publish_all :update, ["updated", :team_id]
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type(:create) do
      forbid_unless actor_attribute_equals(:archived_at, nil)
      forbid_unless ValidNextState
      authorize_if actor_attribute_equals(:role, :soc_admin)
      authorize_if actor_attribute_equals(:role, :soc_analyst)
      authorize_if actor_attribute_equals(:role, :service_account)
    end

    policy action_type(:update) do
      forbid_unless actor_attribute_equals(:archived_at, nil)
      forbid_unless ValidNextState
      authorize_if actor_attribute_equals(:role, :soc_admin)
      authorize_if actor_attribute_equals(:role, :soc_analyst)
      authorize_if actor_attribute_equals(:role, :service_account)
      authorize_if changing_relationship(:comment)
      authorize_if changing_relationship(:file)
    end

    policy action_type(:read) do
      forbid_unless actor_attribute_equals(:archived_at, nil)
      authorize_if actor_attribute_equals(:role, :soc_admin)
      authorize_if actor_attribute_equals(:role, :soc_analyst)
      authorize_if actor_attribute_equals(:role, :service_account)
      authorize_if expr(team_id == ^actor(:team_id) and escalated == true)
    end
  end

  state_machine do
    initial_states(Status.values())
    default_initial_state(:in_progress)
    state_attribute(:status)

    transitions do
      transition(:*, from: :in_progress, to: Status.values())
      transition(:*, from: :pending, to: Status.values())
      transition(:*, from: :benign, to: @closed_states)
      transition(:*, from: :t_positive, to: @closed_states)
      transition(:*, from: :f_positive, to: @closed_states)
    end
  end

  admin do
    create_actions([])
  end

  json_api do
    type "case"
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, allow_nil?: false, public?: true
    attribute :description, :string
    attribute :internal_note, :string

    attribute :status, Status do
      default :in_progress
      allow_nil? false
      public? true
    end

    attribute :escalated, :boolean do
      allow_nil? false
      default false
      public? true
    end

    attribute :priority, CaseManager.ICM.Enums.RiskLevel, allow_nil?: false, public?: true

    timestamps(public?: true)
  end

  relationships do
    belongs_to :reporter, User, allow_nil?: true
    belongs_to :assignee, User, allow_nil?: true
    belongs_to :team, CaseManager.Teams.Team, allow_nil?: false, public?: true

    many_to_many :alert, CaseManager.ICM.Alert do
      through CaseManager.ICM.CaseAlert
      source_attribute_on_join_resource :case_id
      destination_attribute_on_join_resource :alert_id
    end

    many_to_many :views, CaseManager.ICM.Case.View do
      through CaseManager.ICM.CaseView
      source_attribute_on_join_resource :case_id
      destination_attribute_on_join_resource :view_id
    end

    has_many :comment, CaseManager.ICM.Comment
    has_many :file, CaseManager.ICM.File
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      description "Create a case with related alerts."

      accept [
        :title,
        :description,
        :priority,
        :escalated,
        :internal_note,
        :team_id
      ]

      primary? true

      argument :status, :atom, allow_nil?: false
      argument :alert, {:array, :string}

      change {SanitizeHtml, attribute: :description}
      change {SanitizeHtml, attribute: :internal_note}
      change transition_state(arg(:status))
      change manage_relationship(:alert, type: :append_and_remove)
      change relate_actor(:reporter)
    end

    read :read_paginated do
      description "List cases paginated."

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    read :search do
      description "Search cases."

      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(title, ^arg(:query)) or exists(alert, contains(title, ^arg(:query))))

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    update :update do
      description "Update the case information."

      primary? true
      require_atomic? false

      accept [
        :title,
        :description,
        :priority,
        :escalated,
        :internal_note
      ]

      argument :status, :atom, allow_nil?: false

      change {SanitizeHtml, attribute: :description}
      change {SanitizeHtml, attribute: :internal_note}
      change transition_state(arg(:status))
    end

    update :set_assignee do
      description "Assign a case to a user."
      require_atomic? false

      argument :assignee, :string

      change manage_relationship(:assignee, type: :append_and_remove)
    end

    update :add_comment do
      description "Comment on the case."
      require_atomic? false

      argument :body, :string, allow_nil?: false

      change manage_relationship(
               :body,
               :comment,
               type: :create,
               value_is_key: :body
             )
    end

    update :remove_alert do
      description "Remove an alert related to the case."
      require_atomic? false

      argument :alert_id, :uuid, allow_nil?: false

      change manage_relationship(:alert_id, :alert, type: :remove)
    end

    update :upload_file do
      description "Upload a file and relate it to the case."
      require_atomic? false

      argument :file, :map, allow_nil?: false

      change manage_relationship(:file, type: :create)
    end

    update :escalate do
      description "Escalate a case and thus make it visible to its related team."
      change set_attribute(:escalated, true)
    end

    update :view do
      require_atomic? false
      argument :time, :utc_datetime, default: &DateTime.utc_now/0

      change manage_relationship(:time, :views, type: :direct_control, value_is_key: :time)
    end
  end

  resource do
    plural_name :cases
    description "A case about one or more alerts."
  end

  changes do
    change set_attribute(:updated_at, &DateTime.utc_now/0) do
      where [negate(action_is(:view))]
    end
  end

  preparations do
    prepare build(load: [:team, :assignee])
  end

  aggregates do
    count :no_of_related_alerts, :alert
    max :last_viewed, :views, :time
  end

  calculations do
    calculate :updated_since_last?,
              :boolean,
              expr(is_nil(last_viewed) or datetime_add(last_viewed, 1, :second) <= updated_at) do
      description "Checks if the last_viewed is before the updated_at field with a calculated error of margin."
    end

    calculate :is_closed, :boolean, expr(status in @closed_states), public?: true
  end
end
