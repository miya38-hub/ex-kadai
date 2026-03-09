class HomesController < ApplicationController
allow_unauthenticated_access only: [ :top, :about ]

  def top
    redirect_to books_path if authenticated?
  end

   def about
  end
end
