require 'colorize'

class Comment

  attr_reader :user, :date, :item_id, :content

  def initialize(user, date, item_id, content)
    @user = user
    @date = date
    @item_id = item_id
    @content = content
  end

  def get_vote
  end

end
