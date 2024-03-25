# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Faith.Repo.insert!(%Faith.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Faith.Repo
now = DateTime.utc_now() |> DateTime.truncate(:second)

%Faith.Accounts.User{
  email: "admin@admin.com",
  full_name: "Admin",
  gender: "male",
  admin: true,
  location: "USA",
  date_of_birth: ~D[2001-03-25],
  description: "yeahh boii",
  occupation: "admin",
  education: "admin",
  interests: "admin",
  denomination: "admin",
  preferred_min_age: 18,
  looking_for: "male",
  confirmed_at: now,
  completed_at: now,
  hashed_password: Bcrypt.hash_pwd_salt("admin")
}
|> Repo.insert!()
