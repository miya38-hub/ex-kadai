class BooksController < ApplicationController
  before_action :set_book, only: [:edit, :update, :destroy]
  before_action :authorize_book!, only: [:edit, :update, :destroy]

  def edit
end

def update
  if @book.update(book_params)
    redirect_to book_path(@book), notice: "You have updated book successfully.", status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end

def destroy
  @book.destroy
  redirect_to books_path, notice: "削除しました", status: :see_other
end

  def create
    @book = Book.new(book_params)
    @book.user = current_user

    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @user = current_user
      @books = Book.all 
      render :index, status: :unprocessable_entity
    end
  end

  def index
    from = 1.week.ago.beginning_of_day
    to   = Time.current.end_of_day

    join_sql = ActiveRecord::Base.send(
      :sanitize_sql_array,
      ["LEFT JOIN favorites ON favorites.book_id = books.id AND favorites.created_at BETWEEN ? AND ?", from, to]
    )

    base = Book
      .joins(join_sql)
      .select("books.*, COUNT(favorites.id) AS weekly_favorites_count")
      .group("books.id")
      .order("weekly_favorites_count DESC")

    @books = base.includes(:user) # 一覧表示用（N+1防止）
    @weekly_rank_books = base.includes(:user).limit(5) # ← ランキング用（上位5件）

    @book = Book.new
    @user = current_user

    @books =
      if params[:sort] == "score"
        Book.order(score: :desc)
      else
        Book.order(created_at: :desc)
      end

    if params[:category].present?
      @books = @books.where("category LIKE ?", "%#{params[:category]}%")
    end
  end

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    @user = @book.user
    @book_new = Book.new
    @book_comments = @book.book_comments.includes(:user).order(created_at: :desc)
    @book.increment!(:views_count)
  end

  def category_search
    @category = params[:category]
    @books = Book.includes(:user, :book_comments).where(category: @category)
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def authorize_book!
    @book = Book.find(params[:id])
    return if @book.user_id == current_user.id

    redirect_to books_path, alert: "権限がありません"
  end

  def book_params
    params.require(:book).permit(:title, :body, :score, :category)
  end
end
