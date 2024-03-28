defmodule FaithWeb.UserProfileLive do
  use FaithWeb, :live_view

  alias Faith.Accounts

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100">
      <div class="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow-lg">
        <div class="flex items-center justify-center">
          <img
            src="profile_image.jpg"
            alt="User Profile"
            class="w-24 h-24 rounded-full border-4 border-blue-500"
          />
        </div>
        <h1 class="text-2xl font-semibold text-center mt-4">John Doe</h1>
        <p class="text-gray-600 text-center">Software Engineer</p>
        <div class="mt-6">
          <p class="text-gray-700">Location: New York, USA</p>
          <p class="text-gray-700">Date of Birth: January 15, 1990</p>
          <p class="text-gray-700">Education: Bachelor's in Computer Science</p>
          <p class="text-gray-700">Interests: Web development, hiking, photography</p>
        </div>
        <div class="mt-6 flex justify-center space-x-4">
          <a href="#" class="text-blue-500 hover:underline">Edit Profile</a>
          <a href="#" class="text-blue-500 hover:underline">Logout</a>
        </div>
      </div>
    </div>
    """
  end
end
