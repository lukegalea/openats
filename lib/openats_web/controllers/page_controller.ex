defmodule OpenatsWeb.PageController do
  use OpenatsWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/position_profiles")
  end
end
