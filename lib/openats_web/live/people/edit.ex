defmodule OpenatsWeb.People.Edit do
  use OpenatsWeb, :live_view
  use Phoenix.Component

  on_mount {OpenatsWeb.LiveAuth, :require_authenticated_user}

  @impl
  def mount(params, _, socket) do
    person = Openats.Ats.Person |> Openats.Ats.get!(user_id: params["id"])

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
    <div class="nav">
      <ul>
        <li class="nav-item">
          <.link navigate={Routes.live_path(@socket, OpenatsWeb.People.Edit, @current_user.id)}>Profile</.link>
        </li>
        <li class="nav-item">
          <.link navigate={Routes.live_path(@socket, OpenatsWeb.PositionProfiles.Index)}>Job Postings</.link>
        </li>
      </ul>
    </div>
    <div class="page">
      <div class="page-content">
        <div class="page-header">
          <h1>Your Profile</h1>
        </div>
        <div class="panel">
          <div class="panel__content">
            <.form
              :let={f}
              for={@form}
              phx-submit="save"
            >
              <div class="form-control">
                <%= label f, :name, class: "form-label" %>
                <%= text_input f, :name, class: "text-field" %>
                <%= error_tag f, :name %>
              </div>
              
              <%= submit "Save", class: "button" %>
            </.form>
          </div>
        </div>
      </div>
    </div>
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
