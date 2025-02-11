defmodule CaseManager.Configuration.Setting do
  @moduledoc """
  Resource used to store application wide settings in a persitent manner.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Configuration,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("setting")
    repo(CaseManager.Repo)
  end

  attributes do
    uuid_primary_key :id

    attribute :key, :string do
      allow_nil? false
      public? true
    end

    attribute :value, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :file, CaseManager.Configuration.File
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :set_setting do
      argument :key, :string, allow_nil?: false
      argument :value, :string, allow_nil?: false

      upsert? true
      upsert_identity :key

      change set_attribute(:key, arg(:key))
      change set_attribute(:value, arg(:value))
    end

    create :upload_file do
      argument :key, :string, allow_nil?: false
      argument :value, :string, allow_nil?: false
      argument :file, :map, allow_nil?: false

      upsert? true
      upsert_identity :key

      change set_attribute(:key, arg(:key))
      change set_attribute(:value, arg(:value))

      change manage_relationship(:file, type: :direct_control)
    end
  end

  identities do
    identity :key, [:key]
  end
end
