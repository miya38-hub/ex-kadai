class FavoritesController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    current_user.favorites.find_or_create_by!(book: @book)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: book_path(@book) }
    end
  end

  def destroy
    @book = Book.find(params[:book_id])
    current_user.favorites.where(book: @book).destroy_all

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: book_path(@book) }
    end
  end
end
