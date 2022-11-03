defmodule OpenatsWeb.PositionProfiles.New do
  use OpenatsWeb, :live_view
  use Phoenix.Component

  @impl
  def mount(params, _, socket) do
    form = Openats.Ats.PositionProfile
      |> AshPhoenix.Form.for_create(
        :create,
        api: Openats.Ats,
        forms: [auto?: true]
      )
    socket =
      assign(socket,
        form: form
      )

    {:ok, socket}
  end

  @impl
  def render(assigns) do
    ~H"""
    <h1>Create a New Job Posting</h1>
    <ul id="profiles">
    <.form
      :let={f}
      for={@form}
      phx-submit="save"
    >
      <%= label f, :name %>
      <%= text_input f, :name %>
      <%= error_tag f, :name %>

      <%= label f, :description %>
      <%= textarea f, :description %>
      <%= error_tag f, :description %>

      <%= submit "Save" %>
    </.form>
    </ul>
    """
  end

  @impl
  def handle_event("save", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    case AshPhoenix.Form.submit(form) do
      {:ok, result} ->
        Openats.Ats.PositionOpening
        |> Ash.Changeset.for_create(:open, %{position_profile_id: result.id, name: "default"})
        |> Openats.Ats.create!()
        {:noreply, push_navigate(socket, to: "/position_profiles/")}
      {:error, form} ->
        assign(socket, :form, form)
    end
  end
end
