class UsersController < ApplicationController
  before_action :is_matching_login_user, only: [ :edit, :update ]
  allow_unauthenticated_access only: [ :new, :create ]

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "You have updated user successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user) # 登録と同時にログイン扱い
      redirect_to user_path(@user), notice: "Signed up successfully.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @users = User.all
    @user  = current_user
    @book  = Book.new
  end

  def show
    @user = User.find(params[:id])
    @book = Book.new
    @books = @user.books

    today = Time.zone.today

    today_range     = today.beginning_of_day..today.end_of_day
    yesterday       = today - 1
    yesterday_range = yesterday.beginning_of_day..yesterday.end_of_day


    this_week_start = today.beginning_of_week
    this_week_end   = today.end_of_week
    this_week_range = this_week_start.beginning_of_day..this_week_end.end_of_day

    last_week_start = (today - 1.week).beginning_of_week
    last_week_end   = (today - 1.week).end_of_week
    last_week_range = last_week_start.beginning_of_day..last_week_end.end_of_day

    # ① まず count を全部作る（ここが重要）
    @today_books_count     = @user.books.where(created_at: today_range).count
    @yesterday_books_count = @user.books.where(created_at: yesterday_range).count
    @this_week_books_count = @user.books.where(created_at: this_week_range).count
    @last_week_books_count = @user.books.where(created_at: last_week_range).count

    # ② 差分（数）
    @day_diff  = @today_books_count - @yesterday_books_count
    @week_diff = @this_week_books_count - @last_week_books_count

    # ③ 前日比%（昨日が0ならnil）
    @day_percent =
      if @yesterday_books_count.positive?
        ((@day_diff.to_f / @yesterday_books_count) * 100).round(1)
      end

    # ④ 先週比%（先週が0ならnil）
    @week_percent =
      if @last_week_books_count.positive?
        ((@week_diff.to_f / @last_week_books_count) * 100).round(1)
      end

    start_date = 6.days.ago.to_date
    end_date   = Time.zone.today

    daily_hash = @user.books
      .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
      .group("DATE(created_at)")
      .count
      .transform_keys { |k| k.is_a?(Date) ? k : k.to_date }

    @daily_book_counts = (start_date..end_date).map do |date|
      [ date, daily_hash[date] || 0 ]
    end
  end

  def following
    @user = User.find(params[:id])
    @users = @user.followings
  end

  def followers
    @user = User.find(params[:id])
    @users = @user.followers
  end

  def daily_count
    @user = User.find(params[:id])

    date =
      begin
        Date.parse(params[:date])
      rescue
        Time.zone.today
      end

    range  = date.beginning_of_day..date.end_of_day
    @count = @user.books.where(created_at: range).count
    @date  = date

    render partial: "users/daily_count", locals: { date: @date, count: @count }
  end

  private

  # name, email_address, password, password_confirmation を許可
  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :introduction, :profile_image)
  end

  def is_matching_login_user
    return redirect_to new_session_path, status: :see_other unless current_user

    # URLのidが自分じゃなければ自分の詳細へ
    if params[:id].to_i != current_user.id
      redirect_to user_path(current_user), status: :see_other
    end
  end
end
