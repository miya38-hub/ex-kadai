class BookCommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @book_comment = current_user.book_comments.new(book_comment_params)
    @book_comment.book = @book
    @book_comments = @book.book_comments.includes(:user).order(created_at: :desc)

    respond_to do |format|
      if @book_comment.save
        format.turbo_stream
        format.html { redirect_to book_path(@book) }
      else
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { render "books/show", status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @book = Book.find(params[:book_id])
    @book_comment = @book.book_comments.find(params[:id])
    @book_comment.destroy if @book_comment.user == current_user
    @book_comments = @book.book_comments.includes(:user).order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to book_path(@book) }
    end
  end

  private

  def book_comment_params
    params.require(:book_comment).permit(:comment)
  end
end
