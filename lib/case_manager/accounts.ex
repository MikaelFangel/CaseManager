defmodule CaseManager.Accounts do
  @moduledoc false
  use Ash.Domain,
    otp_app: :case_manager

  resources do
    resource CaseManager.Accounts.Token

    resource CaseManager.Accounts.User do
      define :create_user, action: :register_with_password
      define :list_user, action: :read
      define :get_user, action: :read, get_by: :id
    end
  end
end
