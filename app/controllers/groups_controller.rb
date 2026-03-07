class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :new_mail, :send_mail]
  before_action :require_owner, only: [:edit, :update, :new_mail, :send_mail]

  def index
    @groups = Group.includes(:owner, image_attachment: :blob).order(created_at: :desc)
  end

  def show
    @group = Group.includes(:users, image_attachment: :blob).find(params[:id])
  end

  def new
    @group = Group.new
  end

  def create
    @group = current_user.owned_groups.build(group_params)

    if @group.save
      # 作成者をメンバーにもする（GroupUser作成）
      @group.group_users.create!(user: current_user)

      redirect_to group_path(@group), notice: "グループを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to group_path(@group), notice: "グループを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new_mail
  end

def send_mail
  @title = params[:mail_title]
  @content = params[:mail_content]

  if @title.blank? || @content.blank?
    flash.now[:alert] = "タイトルと本文を入力してください"
    render :new_mail, status: :unprocessable_entity
    return
  end

  # メール送信処理を一旦停止
  # @group.users.where.not(email_address: nil).find_each do |user|
  #   GroupMailer.notice_event(user, @group, @title, @content).deliver_now
  # end

  render :send_mail_result
end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def require_owner
    return if @group.owner_id == current_user.id
    redirect_to group_path(@group), alert: "オーナーのみ編集できます"
  end

  def group_params
    params.require(:group).permit(:name, :introduction, :image)
  end
end
