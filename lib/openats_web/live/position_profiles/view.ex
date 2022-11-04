defmodule OpenatsWeb.PositionProfiles.View do
  use OpenatsWeb, :live_view

  on_mount {OpenatsWeb.LiveAuth, :require_authenticated_user}

  @impl
  def mount(params, _, socket) do
    position_opening = socket.assigns.profile.position_openings |> Enum.at(0)

    current_person =
      Openats.Ats.Person
      |> Openats.Ats.get!(user_id: socket.assigns.current_user.id)
      |> Openats.Ats.load!(:candidates)

    has_applied =
      current_person.candidates
      |> Enum.any?(fn candidate -> candidate.position_opening_id == position_opening.id end)

    profile =
      Openats.Ats.PositionProfile
      |> Openats.Ats.get!(id: params["id"])
      |> Openats.Ats.load!(:position_openings)

    assign(socket,
      form: form,
      current_person: current_person,
      profile: profile,
      position_opening: position_opening
    )

    {:ok, socket}
  end

  @impl
  def render(assigns) do
    ~H"""
    <h1>Position Profile <button type="button" phx-click="apply">Apply Now</button></h1>

    <h2>Name</h2>
    <%= @profile.name %>

    <h2>Description</h2>
    <%= @profile.description %>
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
