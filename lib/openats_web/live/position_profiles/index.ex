defmodule OpenatsWeb.PositionProfiles.Index do
  use OpenatsWeb, :live_view
  use Phoenix.Component
  alias OpenatsWeb.Components.ListItem

  @impl true
  def mount(_params, _, socket) do
    form =
      Openats.Ats.PositionOpening |> AshPhoenix.Form.for_create(:open, api: Openats.Ats, forms: [auto?: true])
    socket =
      assign(socket,
        form: form
      )

    socket = AshPhoenix.LiveView.keep_live(socket, :profiles, fn _socket ->
      Openats.Ats.PositionProfile |> Openats.Ats.read!()
    end, subscribe: "position_profile:created", results: :lose)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Job Postings <.link navigate={Routes.live_path(@socket, OpenatsWeb.PositionProfiles.New)}><button>Add</button></.link></h1>
    <ul id="profiles">
    <%= for profile <- @profiles do %>
      <ListItem.list route={Routes.live_path(@socket, OpenatsWeb.PositionProfiles.View, profile.id)}>
        <%= profile.name %>
      </ListItem.list>
    <% end %>
    </ul>
    """
  end

  @impl true
  def handle_event("save", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    case AshPhoenix.Form.submit(form) do
      {:ok, _result} ->
        {:noreply, socket}
      {:error, form} ->
        assign(socket, :form, form)
    end
  end

  @impl true
  def handle_info(%{topic: topic, payload: %Ash.Notifier.Notification{}}, socket) do
    socket = AshPhoenix.LiveView.handle_live(socket, topic, [:profiles])
    {:noreply, socket}
  end
end
