defmodule CaseManager.Accounts do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager, extensions: [AshAdmin.Domain, AshPhoenix, AshJsonApi.Domain]

  alias CaseManager.Accounts.User

  admin do
    show? true
  end

  resources do
    resource CaseManager.Accounts.Token

    resource User do
      define :create_user, action: :register_with_password
      define :list_user, action: :read, default_options: [load: :full_name]
      define :get_user, action: :read, get_by: :id
      define :search_users, action: :search, args: [:query], default_options: [load: :full_name]
      define :update_user, action: :update
      define :delete_user, action: :destroy
    end

    resource CaseManager.Accounts.ApiKey do
      define :create_api_key, action: :create
      define :list_api_keys, action: :read
      define :get_api_key, action: :read, get_by: :id
      define :delete_api_key, action: :destroy
    end
  end
end
