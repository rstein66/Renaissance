defmodule RenaissanceWeb.RegisterController do
  use RenaissanceWeb, :controller
  alias Renaissance.{User, Users}
  alias RenaissanceWeb.Helpers.{Auth}

  def new(conn, _params) do
    changeset = User.changeset(%User{})

    if Auth.signed_in?(conn) do
      conn
      |> put_flash(:error, "You're already logged in...")
      |> redirect(to: Routes.auction_path(conn, :index))
    else
      render(conn, "register.html", changeset: changeset)
    end
  end

  def register(conn, params) do
    case Users.register_user(params["user"]) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "You have successfully signed up!")
        |> redirect(to: Routes.login_path(conn, :login))

      {:error, changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end
end
