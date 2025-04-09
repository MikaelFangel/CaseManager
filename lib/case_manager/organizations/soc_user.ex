defmodule CaseManager.Organizations.SOCUser do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Organizations, data_layer: AshPostgres.DataLayer

  postgres do
    table "soc_users"
    repo(CaseManager.Repo)
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    belongs_to :user, CaseManager.Accounts.User do
      primary_key? true
      allow_nil? false
      public? true
    end

    belongs_to :soc, CaseManager.Organizations.SOC do
      primary_key? true
      allow_nil? false
      public? true
    end
  end
end
