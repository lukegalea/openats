defmodule Openats.Ats.Router do
  # The registry must be explicitly provided here
  use AshJsonApi.Api.Router, api: Openats.Ats, registry: Openats.Ats.Registry
end
