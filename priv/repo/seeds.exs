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
  denomination: "catholic",
  preferred_min_age: 18,
  looking_for: "male",
  confirmed_at: now,
  completed_at: now,
  hashed_password: Bcrypt.hash_pwd_salt("admin")
}
|> Repo.insert!()

%Faith.Accounts.User{
  email: "user1@gmail.com",
  full_name: "Ma Nepali",
  gender: "male",
  admin: false,
  location: "Khape",
  date_of_birth: ~D[2001-03-25],
  description: "yeahh boii",
  occupation: "Berojgar",
  education: "SLC",
  interests: "Money",
  denomination: "catholic",
  preferred_min_age: 18,
  looking_for: "female",
  confirmed_at: now,
  completed_at: now,
  hashed_password: Bcrypt.hash_pwd_salt("user")
}
|> Repo.insert!()

%Faith.Accounts.User{
  email: "user@example.com",
  full_name: "John Doe",
  gender: "male",
  admin: false,
  location: "Canada",
  date_of_birth: ~D[1990-08-10],
  description: "Loves hiking and photography",
  occupation: "Software Engineer",
  education: "Master's Degree",
  interests: "Nature, Music",
  denomination: "Protestant",
  preferred_min_age: 22,
  looking_for: "female",
  confirmed_at: now,
  completed_at: now,
  hashed_password: "$2b$12$Xl6j8Yjz3vJZ4h4e0Qw6OuQyV8aGp1v6RQyNwX5Ku5z8W3J9oZ5eS"
}
|> Repo.insert!()

%Faith.Accounts.User{
  email: "jane@example.com",
  full_name: "Jane Smith",
  gender: "female",
  admin: false,
  location: "Australia",
  date_of_birth: ~D[1985-05-20],
  description: "Passionate about art and travel",
  occupation: "Artist",
  education: "High School",
  interests: "Painting, Cooking",
  denomination: "Other",
  preferred_min_age: 25,
  looking_for: "male",
  confirmed_at: now,
  completed_at: now,
  hashed_password: "$2b$12$Yz4k8Xjw9vKZ3h2f0Qw8OuRyV8bGp2v6RQyNwY5Ku5z8W3J9oZ5eS"
}
|> Repo.insert!()

%Faith.Accounts.User{
  email: "laura@example.com",
  full_name: "Laura Johnson",
  gender: "female",
  admin: false,
  location: "United Kingdom",
  date_of_birth: ~D[1992-09-15],
  description: "Enjoys reading and hiking",
  occupation: "Librarian",
  education: "Master's Degree",
  interests: "Literature, Nature",
  denomination: "Anglican",
  preferred_min_age: 28,
  looking_for: "male",
  confirmed_at: now,
  completed_at: now,
  hashed_password: "$2b$12$Zm8k9Yjw9vKZ3h2f0Qw8OuRyV8bGp2v6RQyNwZ5Ku5z8W3J9oZ5eS"
}
|> Repo.insert!()

%Faith.Accounts.User{
  email: "alex@example.com",
  full_name: "Alex Rodriguez",
  gender: "male",
  admin: false,
  location: "Spain",
  date_of_birth: ~D[1988-06-05],
  description: "Passionate about cooking and travel",
  occupation: "Chef",
  education: "Culinary School",
  interests: "Food, Photography",
  denomination: "Other",
  preferred_min_age: 24,
  looking_for: "female",
  confirmed_at: now,
  completed_at: now,
  hashed_password: "$2b$12$Yz4k8Xjw9vKZ3h2f0Qw8OuRyV8bGp2v6RQyNwY5Ku5z8W3J9oZ5eS"
}
|> Repo.insert!()
