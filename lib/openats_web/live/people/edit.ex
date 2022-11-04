defmodule OpenatsWeb.People.Edit do
  use OpenatsWeb, :live_view
  use Phoenix.Component

  @impl
  def mount(params, _, socket) do
    person = Openats.Ats.Person |> Openats.Ats.get!(user_id: params["id"])
    IO.inspect(person)

    form =
      person
      |> AshPhoenix.Form.for_update(
        :update,
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
    <h1>Your Profile</h1>
    <.form
      :let={f}
      for={@form}
      phx-submit="save"
    >
      <%= label f, :name %>
      <%= text_input f, :name %>
      <%= error_tag f, :name %>

      <%= submit "Save" %>
    </.form>
    """
  end

  @impl
  def handle_event("save", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    case AshPhoenix.Form.submit(form) do
      {:ok, result} ->
        {:noreply, push_navigate(socket, to: "/position_profiles/")}

      {:error, form} ->
        assign(socket, :form, form)
    end
  end
end
