defmodule CaseManager.Cases.Comment do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Cases,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :case_id, :uuid do
      allow_nil? false
    end

    attribute :user_id, :uuid do
      allow_nil? false
    end

    attribute :body, :string do
      allow_nil? false
    end

    timestamps()
  end

  postgres do
    table "comment"
    repo CaseManager.Repo

    references do
      reference :case, on_delete: :delete, on_update: :update, name: "comment_to_case_fkey"
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  # TODO: add relationship to a user
  relationships do
    belongs_to :case, CaseManager.Cases.Case
  end
end
