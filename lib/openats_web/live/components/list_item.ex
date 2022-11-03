defmodule OpenatsWeb.Components.ListItem do
  use Phoenix.Component

  slot :inner_block, required: true
  slot :util

  attr :route, :any, required: true
  
  def list(assigns) do
    assigns = assign_new(assigns, :success, fn -> false end)

    success_char = if assigns.success, do: "🎉 ", else: ""

    ~H"""
    <li class="list-item">
      <.link navigate={@route}>
        <div class="list-item__content">
            <div class="list-item__title"><%= render_slot(@inner_block) %></div>
          </div>
        <div class="list-item__util"><%= render_slot(@util) %></div>
      </.link>
    </li>
    """
  end
end
