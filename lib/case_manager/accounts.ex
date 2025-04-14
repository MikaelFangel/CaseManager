defmodule CaseManager.Accounts do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource CaseManager.Accounts.Token

    resource CaseManager.Accounts.User do
      define :create_user, action: :register_with_password
      define :list_user, action: :read, default_options: [load: :full_name]
      define :get_user, action: :read, get_by: :id
    end
  end
end
