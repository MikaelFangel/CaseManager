defmodule CaseManager.Cases.Case do
  @moduledoc """
  Resource that represents a single case in the system.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Cases,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine]

  @valid_states [:in_progress, :pending, :t_positive, :f_positive, :benign]
  @closed_states [:t_positive, :f_positive, :benign]

  postgres do
    table "case"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "case_to_team_fkey"
    end
  end

  pub_sub do
    module CaseManagerWeb.Endpoint

    prefix "case"
    publish :create, ["created"]
  end

  policies do
    policy action_type(:create) do
      forbid_unless AshStateMachine.Checks.ValidNextState
      authorize_if CaseManager.Policies.MSSPCreatePolicy
    end

    policy action_type(:update) do
      forbid_unless AshStateMachine.Checks.ValidNextState
      authorize_if CaseManager.Policies.MSSPCreatePolicy
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  state_machine do
    initial_states(@valid_states)
    default_initial_state(:in_progress)
    state_attribute(:status)

    transitions do
      transition(:*, from: :in_progress, to: @valid_states)
      transition(:*, from: :pending, to: @valid_states)
      transition(:*, from: :benign, to: @closed_states)
      transition(:*, from: :t_positive, to: @closed_states)
      transition(:*, from: :f_positive, to: @closed_states)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, allow_nil?: false
    attribute :description, :string
    attribute :assignee_id, :uuid
    attribute :team_id, :uuid, allow_nil?: false
    attribute :escalated, :boolean, allow_nil?: false
    attribute :internal_note, :string

    attribute :status, :atom do
      constraints one_of: @valid_states
      default :in_progress
      allow_nil? false
      public? true
    end

    attribute :priority, :atom do
      constraints one_of: [:info, :low, :medium, :high, :critical]
      allow_nil? false
    end

    timestamps()
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

  actions do
    create :create do
      accept [
        :title,
        :description,
        :status,
        :priority,
        :escalated,
        :assignee_id,
        :team_id,
        :internal_note
      ]

      argument :status, :atom
      change transition_state(arg(:status))

      argument :alert, {:array, :string}

      change manage_relationship(:alert,
               type: :append_and_remove,
               on_no_match: :create
             )
    end

    read :read do
      primary? true
      prepare build(load: [:team])
    end

    read :read_paginated do
      prepare build(load: [:team])

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    update :update do
      accept [
        :title,
        :description,
        :priority,
        :escalated,
        :assignee_id,
        :internal_note
      ]

      argument :status, :atom
      change transition_state(arg(:status))

      primary? true
    end

    update :escalate do
      change set_attribute(:escalated, true)
    end
  end

  code_interface do
    define :escalate, args: []
  end

  resource do
    plural_name :cases
  end
end
