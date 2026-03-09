class MessagesController < ApplicationController
  def create
    room = Room.find(message_params[:room_id])

    # そのルームの参加者じゃないなら拒否
    unless room.entries.exists?(user_id: current_user.id)
      redirect_to root_path, alert: "権限がありません"
      return
    end

    @message = current_user.messages.build(message_params)

    if @message.save
      redirect_to room_path(room)
    else
      redirect_to room_path(room), alert: @message.errors.full_messages.join(", ")
    end
  end

  def show
    @room = Room.find(params[:id])
    @messages = @room.messages.includes(:user).order(:created_at) # ←これ大事
    @message = Message.new
  end

  private

  def message_params
    params.require(:message).permit(:content, :room_id)
  end
end
