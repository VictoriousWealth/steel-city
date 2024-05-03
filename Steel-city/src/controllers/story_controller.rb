require "require_all"

get "/create-story" do
  @myTitle = "Create"
  erb :writing_story_page
end

post "/buy-story/:storyid" do
  @error = nil
  story_id = params[:storyid].to_i

  if session["logged_in"] then
    @user_id = session["currentuser"]
  end

  begin
    db = SQLite3::Database.new 'database.sqlite3'
      if User.enough_popcorns?(story_id, @user_id) then
        story = Story[storyid: story_id]
        user = User[userid: @user_id]

        bought_story = BoughtStory.new
        bought_story.storyid = story_id
        bought_story.userid = @user_id
        bought_story.save_changes

        user.popcorns -= story.price
        user.save_changes

        redirect "/buy-confirmation/#{story_id}"
      else
        @error = "You don't have enough popcorns to purchase this story."
      end
  rescue SQLite3::Exception => e
    @error = "Database error: #{e.message}"
  ensure
    db.close if db
  end
  redirect "story_page/#{story_id}"
end

get "/buy-confirmation/:storyid" do
    @story_id = params[:storyid].to_i
    @bought_story_title = Story[@story_id].title
    erb :buy_confirmation
end

get "/story-page/:storyid" do

  @error = nil
  story_id = params[:storyid].to_i
  story = Story[storyid: story_id]

  if session["logged_in"] then
    @user_id = session["currentuser"]
  end
  if session["logged_in"] && BoughtStory.entry_exists?(story_id, @user_id) then
    @bought_story = true
  end

  @title = story.title
  @body = story.content
  @price = story.price
  @blurb = story.blurb
  @genre = story.genre
  @storyID = story.storyid
  @writerID = story.writerid
  begin
    db = SQLite3::Database.new 'database.sqlite3'
      sql = "SELECT username FROM users WHERE userid = ?"
      @author = db.get_first_value(sql,story.writerid)
  rescue SQLite3::Exception => e
    @error = "Database error: #{e.message}"
  ensure
    db.close if db
  end

  erb :story_page
end

post "/submit-story" do
    @title = params.fetch("story-title", "")
    @body = params.fetch("story-content", "")
    @genre = params.fetch("genre","")
    @blurb = params.fetch("blurb-content","")
    @price = params.fetch("price","")
    @error = nil
    if @price.to_f==0.0
        @error="Invalid price"
    end
    begin
      db = SQLite3::Database.new 'database.sqlite3'
        story=Story.new
        numstories=Story.all.count()
        story.storyid=numstories+1
        story.title=@title
        story.content=@body
        story.price=@price.to_f
        story.blurb=@blurb
        story.genre=@genre
        story.releasedate=Date.today.strftime("%d/%m/%y")
        story.writerid=session["currentuser"]
        sql = "SELECT username FROM users WHERE userid = ?"
        @author = db.get_first_value(sql,story.writerid)
        @storyID = story.storyid
        story.save_changes
        session["logged_in"] = true
        
    rescue SQLite3::Exception => e
      @error = "Database error: #{e.message}"
    ensure
      db.close if db
    end
    #should redirect to relevant story page
    erb :story_page
end

get "/user-stories/:userid" do
  user_id = params[:userid].to_i
  begin
    db = SQLite3::Database.new 'database.sqlite3'
      sql = "SELECT title, blurb FROM stories WHERE writerid = ?"
      result = db.execute(sql,user_id)
      @story_list = result.map do |row|
        {
          title: row[0],  # Assuming requestid is the first column
          blurb: row[1],     # Assuming userid is the second column
        }
      end
  rescue SQLite3::Exception => e
    @error = "Database error: #{e.message}"
  ensure
    db.close if db
  end
  
  erb :user_stories
end