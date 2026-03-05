class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update]
  before_action :require_owner, only: [:edit, :update]

  def index
    @groups = Group.includes(:owner, image_attachment: :blob).order(created_at: :desc)
  end

  def show
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
