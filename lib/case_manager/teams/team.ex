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
      argument :email, {:array, :string}, allow_nil?: true
      argument :phone, {:array, :map}, allow_nil?: true

      change manage_relationship(:ip, type: :create)
      change manage_relationship(:email, type: :create, value_is_key: :email)
      change manage_relationship(:phone, type: :create)
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
      primary? true
      prepare(build(sort: [name: :asc]))

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    defaults [:read, :destroy, update: :*]
  end

  code_interface do
    define :read_by_name_asc
    define :add_case, args: [:case]
    define :add_alert, args: [:alert]
  end
end
