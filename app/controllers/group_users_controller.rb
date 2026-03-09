class GroupUsersController < ApplicationController
  def create
    group = Group.find(params[:group_id])

    unless group.group_users.exists?(user_id: current_user.id)
      group.group_users.create(user: current_user)
    end

    redirect_to group_path(group), notice: "グループに参加しました"
  end

  def destroy
    group = Group.find(params[:group_id])
    group_user = group.group_users.find_by(user_id: current_user.id)

    if group_user
      group_user.destroy
    end

    redirect_to group_path(group), notice: "グループを退会しました"
  end
end
