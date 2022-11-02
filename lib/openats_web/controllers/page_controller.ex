defmodule OpenatsWeb.PageController do
  use OpenatsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
