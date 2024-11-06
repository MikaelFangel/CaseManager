defmodule CaseManager.Cases.File do
  @moduledoc """
  Resource for file uploads.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    data_layer: AshPostgres.DataLayer,
    domain: CaseManager.Cases

  postgres do
    table "file"
    repo CaseManager.Repo

    references do
      reference :case, on_delete: :delete, on_update: :update, name: "file_to_case_fkey"
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :case_id, :uuid, allow_nil?: false
    attribute :filename, :string
    attribute :content_type, :string
    attribute :binary_data, :binary

    timestamps()
  end

  relationships do
    belongs_to :case, CaseManager.Cases.Case
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true

      accept [
        :case_id,
        :filename,
        :content_type,
        :binary_data
      ]
    end
  end
end
