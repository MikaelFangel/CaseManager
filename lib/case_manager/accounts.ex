defmodule CaseManager.Accounts do
  @moduledoc false
  use Ash.Domain,
    otp_app: :case_manager

  resources do
    resource CaseManager.Accounts.Token
    resource CaseManager.Accounts.User
  end
end
