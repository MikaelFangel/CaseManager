defmodule CaseManager.Teams.Team do
  @moduledoc """
  Resource for managing teams withing the application. Teams is supposed to be an
  entity that are used to group users.
  """
  use Ash.Resource,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "team"
    repo CaseManager.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false

    attribute :type, :atom do
      default :customer
      allow_nil? false
      constraints one_of: [:customer, :mssp]
    end

    timestamps()
  end

  relationships do
    has_many :alert, CaseManager.Alerts.Alert
    has_many :case, CaseManager.Cases.Case
    has_many :ip, CaseManager.Teams.IP
    has_many :email, CaseManager.Teams.Email
    has_many :phone, CaseManager.Teams.Phone
  end

  actions do
    create :create do
      accept [:name, :type]

      argument :ip, {:array, :map}, allow_nil?: true
      argument :email, {:array, :map}, allow_nil?: true
      argument :phone, {:array, :map}, allow_nil?: true

      change manage_relationship(:ip, type: :create)
      change manage_relationship(:email, type: :create, value_is_key: :email)
      change manage_relationship(:phone, type: :create)
    end

    update :update do
      primary? true
      require_atomic? false
      accept [:name, :type]

      argument :ip, {:array, :map}, allow_nil?: true
      argument :email, {:array, :map}, allow_nil?: true
      argument :phone, {:array, :map}, allow_nil?: true

      change manage_relationship(:ip, type: :direct_control)
      change manage_relationship(:email, type: :direct_control, value_is_key: :email)
      change manage_relationship(:phone, type: :direct_control)
    end

    update :add_case do
      require_atomic? false

      argument :case, :map, allow_nil?: false

      change manage_relationship(:case, type: :create)
    end

    update :add_alert do
      require_atomic? false

      argument :alert, :map, allow_nil?: false

      change manage_relationship(:alert, type: :create)
    end

    read :read_by_name_asc do
      primary? false
      prepare(build(sort: [name: :asc]))

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    defaults [:read, :destroy]
  end

  code_interface do
    define :read_by_name_asc
    define :add_case, args: [:case]
    define :add_alert, args: [:alert]
  end

  aggregates do
    count :alert_with_cases_count, :alert do
      filter expr(case_count > 0)
    end

    count :alert_without_cases_count, :alert do
      filter expr(case_count == 0)
    end

    count :alert_info_count, :alert do
      filter expr(risk_level == :info)
    end

    count :alert_low_count, :alert do
      filter expr(risk_level == :low)
    end

    count :alert_medium_count, :alert do
      filter expr(risk_level == :medium)
    end

    count :alert_high_count, :alert do
      filter expr(risk_level == :high)
    end

    count :alert_critical_count, :alert do
      filter expr(risk_level == :critical)
    end

    count :case_in_progress_count, :case do
      filter expr(status == :in_progress)
    end

    count :case_pending_count, :case do
      filter expr(status == :pending)
    end

    count :case_t_positive_count, :case do
      filter expr(status == :t_positive)
    end

    count :case_f_positive_count, :case do
      filter expr(status == :f_positive)
    end

    count :case_benign_count, :case do
      filter expr(status == :benign)
    end

    count :case_info_count, :case do
      filter expr(priority == :info)
    end

    count :case_low_count, :case do
      filter expr(priority == :low)
    end

    count :case_medium_count, :case do
      filter expr(priority == :medium)
    end

    count :case_high_count, :case do
      filter expr(priority == :high)
    end

    count :case_critical_count, :case do
      filter expr(priority == :critical)
    end
  end
end
