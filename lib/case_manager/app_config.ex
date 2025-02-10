defmodule CaseManager.AppConfig do
  @moduledoc """
  Domain that controls everything related to app configuration.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource CaseManager.AppConfig.Setting do
      define :add_setting, args: [:key, :value], action: :set_setting
      define :upload_file_to_setting, args: [:key, :value, :file], action: :upload_file
    end

    resource CaseManager.AppConfig.File
  end
end
