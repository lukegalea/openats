defmodule OpenatsWeb.Components.Nav do
  use Phoenix.Component
  use OpenatsWeb, :live_view
  
  def nav(assigns) do
    assigns = assign_new(assigns, :success, fn -> false end)

    success_char = if assigns.success, do: "🎉 ", else: ""

    ~H"""
    <ul>
      <li class="nav-item">
        <.link navigate={Routes.live_path(@socket, OpenatsWeb.People.Edit)}>Profile</.link>
      </li>
      <li class="nav-item">
        <.link navigate={Routes.live_path(@socket, OpenatsWeb.PositionProfiles.Index)}>Job Postings</.link>
      </li>
    </ul>
    """
  end
end
