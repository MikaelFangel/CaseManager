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

      # Use the _arg postfix because the argument cannot be the same
      # as the relationship in question.
      argument :ip_arg, :map, allow_nil?: true
      argument :email_arg, :string, allow_nil?: true
      argument :phone_arg, :map, allow_nil?: true

      change manage_relationship(
               :ip_arg,
               :ip,
               type: :create
             )

      change manage_relationship(
               :email_arg,
               :email,
               type: :create,
               value_is_key: :email
             )

      change manage_relationship(
               :phone_arg,
               :phone,
               type: :create
             )
    end

    defaults [:read, :destroy, update: :*]
  end
end
