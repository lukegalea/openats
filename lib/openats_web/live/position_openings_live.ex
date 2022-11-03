defmodule OpenatsWeb.PositionOpeningsLive do
	use OpenatsWeb, :live_view

	def mount(params, _, socket) do
		form =
			Openats.Ats.PositionOpening |> AshPhoenix.Form.for_create(:open, api: Openats.Ats, forms: [auto?: true])
		socket =
			assign(socket,
				form: form
			)

		socket = AshPhoenix.LiveView.keep_live(socket, :openings, fn x ->
			openings = Openats.Ats.PositionOpening |> Openats.Ats.read!()
		end, subscribe: "position_opening:created", results: :lose)

		{:ok, socket}
	end

	def render(assigns) do
		~H"""
		<h1>Position Openings</h1>
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
		<ul id="openings">
		<%= for opening <- @openings do %>
			<li id={opening.id}><%= opening.name %></li>
		<% end %>
		</ul>
		"""
	end

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
