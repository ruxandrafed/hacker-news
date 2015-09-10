class Post

  attr_reader :title, :url, :points, :post_id, :comments

  def initialize(title, url, points, id, comments)
    @title = title
    @url = url
    @points = points
    @post_id = id
    @post_comments = comments
  end

  def comments
    @post_comments
  end

  def add_comment(comment)
    @post_comments << comment
  end

end
