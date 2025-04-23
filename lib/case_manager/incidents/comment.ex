defmodule CaseManager.Incidents.Comment do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "comments"
    repo(CaseManager.Repo)
  end

  actions do
    create :create do
      description "Create a comment."
      primary? true

      accept :*

      change relate_actor(:user)
    end

    read :read do
      description "List all comments."
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      description "Update a comment."
      primary? true
    end

    destroy :delete do
      description "Delete a comment."
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :body, :string do
      allow_nil? false
      public? true
    end

    attribute :visibility, CaseManager.Incidents.Visibility do
      description "Chooses who can see the comment"
      allow_nil? false
      public? true

      default :internal
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
      allow_nil? false
    end
  end
end
