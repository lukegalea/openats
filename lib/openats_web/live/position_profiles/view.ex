defmodule OpenatsWeb.PositionProfiles.View do
  use OpenatsWeb, :live_view
  use Phoenix.Component
  require Ash.Query
  alias OpenatsWeb.Components.ListItem

  on_mount {OpenatsWeb.LiveAuth, :require_authenticated_user}

  @impl
  def mount(params, _, socket) do
    current_user = socket.assigns.current_user

    profile =
      Openats.Ats.PositionProfile
      |> Openats.Ats.get!(id: params["id"])
      |> Openats.Ats.load!(position_openings: [:candidates])

    position_opening = profile.position_openings |> Enum.at(0)

    current_person =
      Openats.Ats.Person
      |> Openats.Ats.get!(user_id: current_user.id)
      |> Openats.Ats.load!(:candidates)

    has_applied =
      current_person.candidates
      |> Enum.any?(fn candidate -> candidate.position_opening_id == position_opening.id end)

    candidates =
      Openats.Ats.Candidate
      |> Ash.Query.filter(position_opening_id: position_opening.id)
      |> Ash.Query.load([:person])
      |> Openats.Ats.read!()

    socket =
      AshPhoenix.LiveView.keep_live(
        socket,
        :candidates,
        fn _socket ->
          candidates =
            Openats.Ats.Candidate
            |> Ash.Query.filter(position_opening_id: position_opening.id)
            |> Ash.Query.load([:person])
            |> Openats.Ats.read!()
        end,
        subscribe: "candidate:created",
        results: :lose
      )

    socket =
      assign(socket,
        current_person: current_person,
        profile: profile,
        position_opening: position_opening,
        has_applied: has_applied
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
          <h1>Position Profile</h1>
          <%= if (!@has_applied) do %>
             <button type="button" phx-click="apply" class="button">Apply Now</button>
           <% else %>
             <div>Applied!</div>
           <% end %>
        </div>
       
        <div class="panel">
          <div class="panel__content">
            <h2>Name</h2>
             <%= @profile.name %>
             
             <h2>Description</h2>
             <%= @profile.description %>
          </div>
        </div>
       
        <%= if (@current_user.account_type == :employer) do %>
          <h2>Applicants</h2>
          <ul class="list">
          <%= for candidate <- @candidates do %>
            <li class="list-item">
              <div class="list-item__content"><%= candidate.person.name %></div>
            </li>
          <% end %>
          </ul>
         <% end %>
      </div>
    </div>
    """
  end

  def handle_event("apply", _params, socket) do
    person = socket.assigns.current_person
    opening_id = socket.assigns.position_opening.id

    Openats.Ats.Candidate
    |> Ash.Changeset.for_create(:apply, %{position_opening_id: opening_id, person_id: person.id})
    |> Openats.Ats.create!()

    socket =
      assign(socket,
        has_applied: true
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: topic, payload: %Ash.Notifier.Notification{}}, socket) do
    socket = AshPhoenix.LiveView.handle_live(socket, topic, [:candidates])
    {:noreply, socket}
  end
end
