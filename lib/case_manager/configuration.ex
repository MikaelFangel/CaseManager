defmodule CaseManager.Configuration do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager, extensions: [AshAdmin.Domain, AshPhoenix]

  admin do
    show? true
  end

  resources do
    resource CaseManager.Configuration.Setting do
      define :get_setting, action: :read, get_by: :key
      define :set_setting, action: :set, args: [:key, :value]
      define :list_settings, action: :read
      define :delete_setting, action: :destroy
    end
  end
end
