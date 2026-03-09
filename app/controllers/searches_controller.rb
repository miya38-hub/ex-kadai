class SearchesController < ApplicationController
  def search
    @range  = params[:range].to_s
    @word   = params[:word].to_s.strip
    @method = params[:method].to_s

    @results =
      if @word.blank?
        Book.none
      elsif @range == "Book"
        search_books(@word, @method).includes(:user)
      elsif @range == "User"
        users = search_users(@word, @method)
        Book.where(user_id: users.select(:id)).includes(:user)
      else
        Book.none
      end
  end

  private

  def search_users(word, method)
    escaped = ActiveRecord::Base.sanitize_sql_like(word)

    case method
    when "perfect"
      User.where(name: word)
    when "forward"
      User.where("name LIKE ?", "#{escaped}%")
    when "backward"
      User.where("name LIKE ?", "%#{escaped}")
    else
      User.where("name LIKE ?", "%#{escaped}%")
    end
  end

  def search_books(word, method)
    escaped = ActiveRecord::Base.sanitize_sql_like(word)

    case method
    when "perfect"
      Book.where(title: word)
    when "forward"
      Book.where("title LIKE ?", "#{escaped}%")
    when "backward"
      Book.where("title LIKE ?", "%#{escaped}")
    else
      Book.where("title LIKE ?", "%#{escaped}%")
    end
  end
end
