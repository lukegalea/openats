defmodule Openats.Ats.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Openats.Ats.PositionOpening
    entry Openats.Ats.PositionProfile
  end
end
