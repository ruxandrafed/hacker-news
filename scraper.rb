require 'nokogiri'
require 'open-uri'
require 'pry'
require_relative 'post'
require_relative 'comment'

class Scraper

  def initialize
    @url = ARGV[0]
  end

  # Creates an instance of Post after scraping content
  def create_post
    post_title = parse_html.css('title')[0].text
    post_url = @url
    points = parse_html.search('.subtext > span:first-child').map { |span| span.inner_text}
    post_points = points[0]
    all_ids = parse_html.search('tr.athing td center a').map { |link| link['id']}
    post_id = all_ids[0].gsub(/[[a-z]_" ""]/,"") # taken from the first upvote button
    @post = Post.new(post_title, post_url, post_points, post_id, parse_comments)
  end

  # Returns array of Comment objects
  def parse_comments
    scraper = parse_html.css('.default')
    all_comments = scraper.map do |node|
      user = node.css('.comhead a:first-child').text
      date = node.css('.comhead a:nth-child(2)').text.to_i
      item_id = node.css('.comhead a:nth-child(2)').map {|link| link['href'][8,10]}
      item_id = item_id[0]
      #content = node.css('.comment').css(':not(.reply)').text
      content = node.css('.comment span:first-child').text.gsub(/reply/, "").gsub(/[-\n]/,"").strip
      Comment.new(user, date, item_id, content)
    end
  end

  # Prints post statistics & all post comments
  def post_statistics
    print "Post Title: ".colorize(:green)
    puts "#{@post.title}".colorize(:yellow)
    print "Post URL: ".colorize(:green)
    puts "#{@post.url}".colorize(:yellow)
    print "Post Points: ".colorize(:green)
    puts "#{@post.points}".colorize(:yellow)
    print "Post ID: ".colorize(:green)
    puts "#{@post.post_id}".colorize(:yellow)
    print "Number of comments: ".colorize(:green)
    puts "#{@post.comments.size}\n".colorize(:yellow)
    puts "Comments:\n".colorize(:green)
    @post.comments.each do |comment|
      puts "#{comment.date} days ago, comment id #{comment.item_id} by #{comment.user}".colorize(:green)
      puts "#{comment.content}\n".colorize(:blue)
    end
  end

  # Returns a nokogiri XML object
  def parse_html
    Nokogiri::HTML(open(@url).read)
  end

  def self.run
    scraper = Scraper.new
    scraper.create_post
    scraper.post_statistics
  end

end

Scraper.run
