defmodule CaseManager.Incidents.Comment do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "comments"
    repo(CaseManager.Repo)
  end

  attributes do
    uuid_primary_key :id

    attribute :body, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :case, CaseManager.Incidents.Case do
      allow_nil? false
    end

    belongs_to :user, CaseManager.Accounts.User do
      allow_nil? false
    end
  end
end
