defmodule CaseManager.ICM.File do
  @moduledoc false
  use Ash.Resource,
    otp_app: :case_manager,
    data_layer: AshPostgres.DataLayer,
    domain: CaseManager.ICM,
    extensions: [AshAdmin.Resource]

  postgres do
    table "file"
    repo CaseManager.Repo

    references do
      reference :case, on_delete: :delete, on_update: :update, name: "file_to_case_fkey"
    end
  end

  admin do
    create_actions([])
  end

  attributes do
    uuid_primary_key :id

    attribute :filename, :string, allow_nil?: false, public?: true
    attribute :content_type, :string, allow_nil?: false, public?: true
    attribute :binary_data, :binary, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    belongs_to :case, CaseManager.ICM.Case
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  resource do
    description "A file in the context of a case."
  end
end
