# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.dev.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Renaissance.Repo.insert!(%Renaissance.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Renaissance.{Repo, Users}

Repo.transaction(fn ->
  Users.insert(%{
    email: "bob@smith.com",
    password: "password"
  })

  Users.insert(%{
    email: "buyer1@dev.com",
    password: "buyer1"
  })

  Users.insert(%{
    email: "seller1@dev.com",
    password: "seller1"
  })
end)
