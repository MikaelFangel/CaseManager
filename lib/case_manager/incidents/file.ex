defmodule CaseManager.Incidents.File do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "files"
    repo(CaseManager.Repo)
  end

  attributes do
    uuid_primary_key :id

    attribute :filename, :string do
      allow_nil? false
      public? true
    end

    attribute :content_type, :string do
      allow_nil? false
      public? true
    end

    attribute :binary_data, :binary do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :case, CaseManager.Incidents.Case
  end
end
