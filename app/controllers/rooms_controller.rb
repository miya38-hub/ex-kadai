class RoomsController < ApplicationController
  def create
    target = User.find(params[:user_id])

    unless current_user.mutual_follow?(target)
      redirect_to user_path(target), alert: "相互フォローの相手にだけDMできます"
      return
    end

    current_room_ids = current_user.entries.pluck(:room_id)
    target_entry = Entry.find_by(user_id: target.id, room_id: current_room_ids)

    if target_entry
      room = target_entry.room
    else
      room = Room.create
      Entry.create(user_id: current_user.id, room_id: room.id)
      Entry.create(user_id: target.id, room_id: room.id)
    end

    redirect_to room_path(room)
  end

  def show
    @room = Room.find(params[:id])

    # 参加者以外NG
    unless @room.entries.exists?(user_id: current_user.id)
      redirect_to root_path, alert: "権限がありません"
      return
    end

    # 相互フォローが崩れたら閲覧NGにしたい場合（保険）
    other_user_id = @room.entries.where.not(user_id: current_user.id).pluck(:user_id).first
    other_user = User.find_by(id: other_user_id)

    if other_user && !current_user.mutual_follow?(other_user)
      redirect_to user_path(other_user), alert: "相互フォローの相手にだけDMできます"
      return
    end

    @messages = @room.messages.includes(:user).order(:created_at)
    @message  = Message.new
  end
end
