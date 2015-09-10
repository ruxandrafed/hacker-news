<p>We&#39;re going to write a simple <a href="https://news.ycombinator.com/" target="_blank">Hacker News</a> scraper. </p>

<p>In case you&#39;re not fully sure what web scraping is, check out <a href="https://www.google.ca/search?q=what+is+a+web+scraper" target="_blank">this useful resource</a>.</p>

<p>We&#39;re going to build Ruby classes that represent a particular Hacker News comment thread.</p>

<h3>Learning Goals</h3>

<p>The main goal is to learn how to translate a pre-existing object model — in this case, Hacker News&#39; model — using OOP in Ruby.</p>

<p>This assignment will also have us:</p>

<ul>
<li>Recalling fundamental/basic HTML and CSS</li>
<li>Learning about the Nokogiri gem</li>
<li>Learning about using <code>ARGV</code> for Command-Line arguments</li>
<li>Learning about the <code>curl</code> command line tool.</li>
<li>Learning about the Ruby&#39;s <code>OpenURI</code> module</li>
<li>Colourizing our output</li>
</ul>

<h3>Objectives</h3>

<h4>Save a HTML Page</h4>

<p>First, we&#39;re going to save a specific HN post as a plain HTML file for us to practice on. As we&#39;re developing a scraper we&#39;ll be tempted to hammer the HN servers, which will almost certainly get everyone temporarily banned. We&#39;ll use the local HTML file to get the scraper working before we create a &quot;live&quot; version.</p>

<p>Note that this implies something about how your class should work: it shouldn&#39;t care how it gets the HTML content.</p>

<p>Visit the Hacker News homepage and click through to a specific post. I&#39;d suggest a cool one, like the <a href="https://news.ycombinator.com/item?id=7663775" target="_blank">Show HN: Velocity.js – Accelerated JavaScript animation (VelocityJS.org)</a> post. You can save the HTML for this page somewhere using the <code>curl</code> command.</p>

<p>SSH into your vagrant box, <code>cd</code> into your project directory, and run the following command:</p>

<pre><code>$ curl https://news.ycombinator.com/item?id=7663775 &gt; post.html
</code></pre>

<p><em>NOTE:</em> The $ is not to be typed in literally, it denotes the command prompt. </p>

<p>This will create a <code>post.html</code> file which contains the HTML from the URL you entered. You&#39;re free to enter another URL.</p>

<h4>Playing around with Nokogiri</h4>

<p>First, make sure the <code>nokogiri</code> gem is installed. We&#39;ll use this to parse the HTML file. You can test this by running irb/pry and typing</p>

<pre><code>require &#39;nokogiri&#39;
</code></pre>

<p>If you get an error that means Nokogiri is not installed. Install it by running this command:</p>

<pre><code>$ gem install nokogiri
</code></pre>

<p>You&#39;ll want to have the <a href="http://nokogiri.org/tutorials/parsing_an_html_xml_document.html" target="_blank">Nokogiri documentation about parsing an HTML document</a> available. Try this from irb/pry:</p>

<pre><code>doc = Nokogiri::HTML(File.open(&#39;post.html&#39;))
</code></pre>

<p>For this to work, make sure you run this ruby code from the same directory as <code>post.html</code>.</p>

<p>What does the Nokogiri object itself look like? Don&#39;t worry about having to sift through it&#39;s innards, but reading <a href="http://ruby.bastardsbook.com/chapters/html-parsing/" target="_blank">Parsing HTML with Nokogiri</a> from The Bastard&#39;s Book of Ruby can give you a feel for how Nokogiri works.</p>

<p>Here&#39;s an example method that takes a Nokogiri document of a Hacker News thread as input and returns an array of commentor&#39;s usernames:</p>

<pre><code>def extract_usernames(doc)
  doc.search(&#39;.comhead &gt; a:first-child&#39;).map do |element|
    element.inner_text
  end
end
</code></pre>

<p>It&#39;s likely been a while since you&#39;ve dealt with <a href="http://css.maxdesign.com.au/selectutorial/" target="_blank">CSS Selectors</a>, which is what the <code>search</code> method is using to select elements off the page. If you&#39;re feeling uncomfortable about them, feel free to revisit that section in the prep course.</p>

<p>What do these other Nokogiri calls return?</p>

<pre><code>doc.search(&#39;.subtext &gt; span:first-child&#39;).map { |span| span.inner_text}
doc.search(&#39;.subtext &gt; a:nth-child(3)&#39;).map {|link| link[&#39;href&#39;] }
doc.search(&#39;.title &gt; a:first-child&#39;).map { |link| link.inner_text}
doc.search(&#39;.title &gt; a:first-child&#39;).map { |link| link[&#39;href&#39;]}
doc.search(&#39;.comment &gt; font:first-child&#39;).map { |font| font.inner_text}
</code></pre>

<p>What is the data structure? Can you call ruby methods on the returned data structure?</p>

<p>Make sure you open up the html page in your browser and poke around the source code to see how the page is structured. What do their tags actually look like? How are those tags represented in the Nokogiri searches?</p>

<h4>Creating Your Object Model</h4>

<p>We want two classes: <code>Post</code> and <code>Comment</code>. A post has many comments and each comment belongs to exactly one post. Let&#39;s build the <code>Post</code> class so it has the following attributes: <code>title</code>, <code>url</code>, <code>points</code>, and <code>item_id</code>, corresponding to the title on Hacker News, the post&#39;s URL, the number of points the post currently has, and the post&#39;s Hacker News item ID, respectively.</p>

<p>Additionally, create two instance methods:</p>

<ol>
<li><code>Post#comments</code> returns all the comments associated with a particular post</li>
<li><code>Post#add_comment</code> takes a <code>Comment</code> object as its input and adds it to the comment list.</li>
</ol>

<p>You&#39;ll have to design the Comment object yourself. What attributes and methods should it support and why?</p>

<p>We could go deeper and add, e.g., a User model, but we&#39;ll stop with Post and Comment.</p>

<h4>Loading Hacker News Into Objects</h4>

<p>We now need code which does the following:</p>

<ol>
<li>Instantiates a Post object</li>
<li>Parses the Hacker News HTML</li>
<li>Creates a new Comment object for each comment in the HTML, adding it to the Post object in (1)</li>
</ol>

<p>Boom... Ship it!</p>

<h4>Command line + parsing the actual Hacker News</h4>

<p>We&#39;re going to learn two new things: the basics of parsing command-line arguments and how to fetch HTML for a website using Ruby. We want to end up with a command-line program that works like this:</p>

<pre><code>$ ruby hn_scraper.rb https://news.ycombinator.com/item?id=5003980
Post title: XXXXXX
Number of comments: XXXXX
... some other statistics we might be interested in -- your choice ...
$
</code></pre>

<p>First, read <a href="http://alvinalexander.com/blog/post/ruby/how-read-command-line-arguments-args-script-program" target="_blank">this blog post about command-line arguments in Ruby</a>. You have used <code>ARGV</code> before. Now, you want to use it to get the URL passed in to your Ruby script.</p>

<p>Second, read about Ruby&#39;s <a href="http://www.ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html" target="_blank">OpenURI</a> module. By requiring &#39;open-uri&#39; at the top of your Ruby program, you can use open with a URL:</p>

<pre><code>require &#39;open-uri&#39;

html_file = open(&#39;http://www.ruby-doc.org/stdlib-2.0.9/libdoc/open-uri/rdoc/OpenURI.html&#39;)
puts html_file.read
</code></pre>

<p>This captures the html from that URL as a <code>StringIO</code> object, which NokoGiri accepts as an argument to <code>NokoGiri::HTML</code>.</p>

<p>Combine these two facts to let the user pass a URL into your program, parse the given Hacker News URL into objects, and print out some useful information for the user.</p>

<h3>Enhancement #1</h3>

<p>Use the <code>colorize</code> gem to colour your output. Design a colour scheme where titles, comments, and any other statistics you have specified each have their own colour scheme.</p>

<h3>Enhancement #2</h3>

<p>Create your own custom exceptions for each of your class types. Consider carefully where failure conditions need to be handled. What are errors that you have had to deal with in your development up to this point? Test conditions such as a local HTML file not being able to be loaded. Perhaps the URL passed on the command line cannot be loaded. How should your app behave in any of these error conditions, or others that you can imagine?</p>

<h3>BONUS!</h3>

<p>Use your combination of <code>ARGV</code>, <code>Nokogiri</code> and <code>OpenURI</code> to scrape content from any of the following sites:</p>

<ul>
<li><a href="http://www.echojs.com" target="_blank">EchoJS</a></li>
<li><a href="http://www.reddit.com/r/ruby/" target="_blank">Ruby Reddit</a></li>
<li><a href="http://www.imgur.com" target="_blank">Imgur</a></li>
</ul>

<p>Can you use the same statistics you applied to HackerNews postings to these other sites? There are similarities to the formats, but the HTML will be different. How can you account for this?</p>
</div></section></div></main></body></html>
