defmodule CaseManager.Organizations.SOCUser do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Organizations, data_layer: AshPostgres.DataLayer

  postgres do
    table "soc_users"
    repo(CaseManager.Repo)
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, CaseManager.Accounts.User do
      allow_nil? false
    end

    belongs_to :soc, CaseManager.Organizations.SOC do
      allow_nil? false
    end
  end
end
