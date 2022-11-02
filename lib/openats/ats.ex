defmodule Openats.Ats do
  use Ash.Api, extensions: [AshJsonApi.Api, AshAdmin.Api]

  resources do
    registry Openats.Ats.Registry
  end

  json_api do
    serve_schema? true
    log_errors? true
    router Openats.Ats.Router
  end

  admin do
    show? true
  end
end
