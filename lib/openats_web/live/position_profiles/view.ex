defmodule OpenatsWeb.PositionProfiles.View do
  use OpenatsWeb, :live_view

  @impl
  def mount(params, _, socket) do
    form =
      Openats.Ats.PositionOpening |> AshPhoenix.Form.for_create(:open, api: Openats.Ats, forms: [auto?: true])
    socket =
      assign(socket,
        form: form
      )

    socket = AshPhoenix.LiveView.keep_live(socket, :profile, fn x ->
      Openats.Ats.PositionProfile |> Openats.Ats.get!(id: params["id"])
    end, subscribe: "position_opening:created", results: :lose)

    {:ok, socket}
  end

  @impl
  def render(assigns) do
    ~H"""
    <h1>Position Profile</h1>

    <h2>Name</h2>
    <%= @profile.name %>

    <h2>Description</h2>
    <%= @profile.description %>

    <ul id="openings">

    </ul>
    """
  end

  @impl
  def handle_event("save", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    case AshPhoenix.Form.submit(form) do
      {:ok, result} ->
        {:noreply, socket}
      {:error, form} ->
        assign(socket, :form, form)
    end
  end

  @impl true
  def handle_info(%{topic: topic, payload: %Ash.Notifier.Notification{}}, socket) do
    socket = AshPhoenix.LiveView.handle_live(socket, topic, [:openings])
    {:noreply, socket}
  end
end
