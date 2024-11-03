defmodule CaseManager.ContactInfos.IP do
  @moduledoc """
  Resource to represents an IP address of either version v4 og v6.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ip"
    repo CaseManager.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :ip, :string, allow_nil?: false, public?: true

    attribute :version, :atom do
      constraints one_of: [:v4, :v6]
      public? true
    end

    timestamps()
  end

  relationships do
    many_to_many :team, CaseManager.Teams.Team do
      through CaseManager.Relationships.TeamIP
      source_attribute_on_join_resource :ip_id
      destination_attribute_on_join_resource :team_id
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
