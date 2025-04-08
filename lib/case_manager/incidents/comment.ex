defmodule CaseManager.Incidents.Comment do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "comments"
    repo(CaseManager.Repo)
  end

  actions do
    create :create do
      primary? true

      accept :*
    end

    read :read do
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      primary? true
    end

    destroy :delete do
    end
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
      public? true
    end

    belongs_to :alert, CaseManager.Incidents.Alert do
      public? true
    end

    belongs_to :user, CaseManager.Accounts.User do
      public? true
      allow_nil? false
    end
  end
end
