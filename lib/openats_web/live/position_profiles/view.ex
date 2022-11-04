defmodule OpenatsWeb.PositionProfiles.View do
  use OpenatsWeb, :live_view
  require Ash.Query

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
      assign(socket,
        current_person: current_person,
        profile: profile,
        position_opening: position_opening,
        has_applied: has_applied,
        candidates: candidates
      )

    {:ok, socket}
  end

  @impl
  def render(assigns) do
    ~H"""
    <h1>
      Position Profile
      <%= if (!@has_applied) do %>
        <button type="button" phx-click="apply">Apply Now</button>
      <% else %>
        Applied!
      <% end %>
    </h1>

    <h2>Name</h2>
    <%= @profile.name %>

    <h2>Description</h2>
    <%= @profile.description %>

    <%= if (@current_user.account_type == :employer) do %>
      <ul>
      <%= for candidate <- @candidates do %>
        <li><%= candidate.person.name %></li>
      <% end %>
      </ul>
    <% end %>
    """
  end

  def handle_event("apply", _params, socket) do
    person = socket.assigns.current_person
    opening_id = socket.assigns.profile.position_opening.id

    Openats.Ats.Candidate
    |> Ash.Changeset.for_create(:apply, %{position_opening_id: opening_id, person_id: person.id})
    |> Openats.Ats.create!()

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: topic, payload: %Ash.Notifier.Notification{}}, socket) do
    socket = AshPhoenix.LiveView.handle_live(socket, topic, [:openings])
    {:noreply, socket}
  end
end
