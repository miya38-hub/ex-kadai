class RelationshipsController < ApplicationController
  def create
    user = User.find(params[:followed_id])
    current_user.follow(user)
    redirect_back fallback_location: user_path(user)
  end

  def destroy
    relationship = Relationship.find(params[:id])
    user = relationship.followed
    current_user.unfollow(user)
    redirect_back fallback_location: user_path(user)
  end
end
