defmodule CaseManager.Incidents.Alert do
  @moduledoc """
  Represents a security alert received from monitoring systems.

  Alerts are the primary input for security incidents and contain
  all relevant metadata for security analysis and case creation.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Incidents,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshJsonApi.Resource, AshCloak],
    notifiers: [Ash.Notifier.PubSub]

  alias CaseManager.Incidents
  alias CaseManager.Incidents.Status

  json_api do
    type "alert"
  end

  postgres do
    table "alerts"
    repo(CaseManager.Repo)
  end

  cloak do
    vault(CaseManager.Vaults.Alert)

    attributes([:description])

    decrypt_by_default([:description])
  end

  actions do
    create :create do
      description "Create a new security alert"
      primary? true

      accept [:alert_id, :title, :description, :severity, :creation_time, :link, :company_id]
    end

    read :read do
      description "List alerts"
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    read :search do
      description "Search alerts by title, description, or alert ID."

      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      pagination offset?: true, keyset?: true, required?: false

      filter expr(contains(title, ^arg(:query)) or contains(alert_id, ^arg(:query)))
    end

    read :older_than do
      description "Find alerts older than specified duration for cleanup"

      argument :duration, :integer do
        allow_nil? false
        description "Number of time units"
        default 6
      end

      argument :unit, :atom do
        allow_nil? false
        description "Time unit (:second, :minute, :hour, :day, :week, :month, :year)"
        default :month
        constraints one_of: [:second, :minute, :hour, :day, :week, :month, :year]
      end

      filter expr(inserted_at <= ago(^arg(:duration), ^arg(:unit)))
    end

    update :update do
      description "Change the alert data"
      accept [:title, :description, :severity]
      primary? true
      require_atomic? false
    end

    update :change_status do
      description "Change the alert status."
      argument :status, Status, allow_nil?: false
      require_atomic? false

      change set_attribute(:status, arg(:status))
    end

    update :add_comment do
      description "Add a comment to an alert"
      require_atomic? false

      argument :body, :string, allow_nil?: false

      change manage_relationship(:body, :comments, type: :create, value_is_key: :body)
    end

    destroy :delete do
      description "Delete an alert"
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    bypass actor_attribute_equals(:super_admin?, true) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if accessing_from(Incidents.Case, :cases)
      authorize_if expr(company.soc.users == ^actor(:id))
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if always()
    end

    policy action_type(:destroy) do
      authorize_if always()
    end
  end

  pub_sub do
    module CaseManagerWeb.Endpoint

    prefix "alert"
    publish :create, [[:company_id, nil], [:id, nil]]
    publish :update, [[:company_id, nil], [:id, nil]]
    publish :change_status, [[:company_id, nil], [:id, nil]]
  end

  validations do
    validate {CaseManager.Validations.Url, attribute: :link, message: "must be a valid HTTP or HTTPS URL"}
  end

  attributes do
    uuid_primary_key :id

    attribute :alert_id, :string do
      description "External alert identifier from the monitoring system"
      allow_nil? false
      public? true
      constraints max_length: 255
    end

    attribute :title, :string do
      description "Brief description of the security alert"
      allow_nil? false
      public? true
      constraints max_length: 500
    end

    attribute :description, :string do
      description "Detailed description of the security alert"
      public? true
      constraints max_length: 5000
    end

    attribute :severity, CaseManager.Incidents.Severity do
      description "Security severity level of the alert"
      allow_nil? false
      public? true
    end

    attribute :status, Status do
      allow_nil? false
      public? true
      default :new
    end

    attribute :creation_time, :utc_datetime do
      description "When the alert was originally created in the monitoring system"
      allow_nil? false
      public? true
    end

    attribute :link, :string do
      description "URL link to the original alert in the monitoring system"
      allow_nil? false
      public? true
      constraints max_length: 2000
    end

    timestamps()
  end

  relationships do
    belongs_to :company, CaseManager.Organizations.Company do
      description "The company this alert belongs to"
      allow_nil? false
      public? true
    end

    many_to_many :cases, CaseManager.Incidents.Case do
      description "Cases that this alert is linked to"
      through CaseManager.Incidents.CaseAlert
      public? true
    end

    has_many :comments, CaseManager.Incidents.Comment do
      description "Comments and notes on this alert"
      public? true
      sort inserted_at: :desc
    end
  end

  identities do
    identity :unique_alert_per_company, [:alert_id, :company_id] do
      message "Alert ID must be unique within the company"
    end
  end
end
