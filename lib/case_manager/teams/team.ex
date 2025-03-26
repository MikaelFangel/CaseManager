defmodule CaseManager.Teams.Team do
  @moduledoc false
  use Ash.Resource,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  alias CaseManager.Teams.ArchivedUser
  alias CaseManager.Teams.User

  postgres do
    table "team"
    repo CaseManager.Repo
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type([:create, :destroy]) do
      forbid_unless actor_attribute_equals(:archived_at, nil)
      authorize_if actor_attribute_equals(:role, :soc_admin)
      authorize_if actor_attribute_equals(:role, :service_account)
    end

    policy action_type(:read) do
      authorize_if accessing_from(User, :team)
      authorize_if accessing_from(ArchivedUser, :team)
      authorize_if actor_attribute_equals(:role, :soc_admin)
      authorize_if actor_attribute_equals(:role, :soc_analyst)
      authorize_if actor_attribute_equals(:role, :service_account)
      authorize_if expr(id == ^actor(:team_id))
    end

    policy action_type([:update]) do
      forbid_unless actor_attribute_equals(:archived_at, nil)
      authorize_if actor_attribute_equals(:role, :soc_admin)
      authorize_if actor_attribute_equals(:role, :service_account)
      authorize_if expr(id == ^actor(:team_id) and actor_attribute_equals(:role, :team_admin))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true

    attribute :type, :atom do
      default :customer
      allow_nil? false
      constraints one_of: [:customer, :mssp]
    end

    timestamps()
  end

  relationships do
    has_many :users, User
    has_many :archived_users, ArchivedUser
    has_many :alert, CaseManager.ICM.Alert
    has_many :case, CaseManager.ICM.Case
    has_many :ip, CaseManager.Teams.IP
    has_many :email, CaseManager.Teams.Email
    has_many :phone, CaseManager.Teams.Phone
  end

  actions do
    create :create do
      description "Add a team."
      accept [:name, :type]

      argument :ip, {:array, :map}, allow_nil?: true
      argument :email, {:array, :map}, allow_nil?: true
      argument :phone, {:array, :map}, allow_nil?: true

      change manage_relationship(:ip, type: :create)
      change manage_relationship(:email, type: :create)
      change manage_relationship(:phone, type: :create)
    end

    update :update do
      description "Update the team information."
      primary? true
      require_atomic? false
      accept [:name, :type]

      argument :ip, {:array, :map}, allow_nil?: true
      argument :email, {:array, :map}, allow_nil?: true
      argument :phone, {:array, :map}, allow_nil?: true

      change manage_relationship(:ip, type: :direct_control)
      change manage_relationship(:email, type: :direct_control)
      change manage_relationship(:phone, type: :direct_control)
    end

    update :add_case do
      description "Add a case to a team."
      require_atomic? false

      argument :case, :map, allow_nil?: false

      change manage_relationship(:case, type: :create)
    end

    update :add_alert do
      description "Add an alert to a team."
      require_atomic? false

      argument :alert, :map, allow_nil?: false

      change manage_relationship(:alert, type: :create)
    end

    read :read do
      description "List all teams by name in acending order."
      primary? true
    end

    read :read_paged do
      description "List all teams by name in acending order paginated."

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    defaults [:destroy]
  end

  resource do
    description "A team of user that can either be a customer or the MSSP itself."
  end

  aggregates do
    count :alert_with_cases_count, :alert, do: filter(expr(case_count > 0))
    count :alert_without_cases_count, :alert, do: filter(expr(case_count == 0))
    count :alert_info_count, :alert, do: filter(expr(risk_level == :info))
    count :alert_low_count, :alert, do: filter(expr(risk_level == :low))
    count :alert_medium_count, :alert, do: filter(expr(risk_level == :medium))
    count :alert_high_count, :alert, do: filter(expr(risk_level == :high))
    count :alert_critical_count, :alert, do: filter(expr(risk_level == :critical))
    count :case_in_progress_count, :case, do: filter(expr(status == :in_progress))
    count :case_pending_count, :case, do: filter(expr(status == :pending))
    count :case_ping_count, :case, do: filter(expr(status == :ping))
    count :case_t_positive_count, :case, do: filter(expr(status == :t_positive))
    count :case_f_positive_count, :case, do: filter(expr(status == :f_positive))
    count :case_benign_count, :case, do: filter(expr(status == :benign))
    count :case_info_count, :case, do: filter(expr(priority == :info))
    count :case_low_count, :case, do: filter(expr(priority == :low))
    count :case_medium_count, :case, do: filter(expr(priority == :medium))
    count :case_high_count, :case, do: filter(expr(priority == :high))
    count :case_critical_count, :case, do: filter(expr(priority == :critical))
  end
end
