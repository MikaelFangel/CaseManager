defmodule CaseManager.Alerts do
  use Ash.Domain

  resources do
    resource CaseManager.Alerts.Alert
  end
end
