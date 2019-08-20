class UIBuilder
  PullRequest = Struct.new(:repo_name, 
                           :author_login,
                           :created_at,
                           :number,
                           :url,
                           :title,
                           :review_requests,
                           :reviews,
                           :comments
                          )

  def initialize(data, stats = false)
      @data = data
      @stats = stats
  end

  def do_render()
    render_badge
    render_header
    render_list_reviews
  end

  private
  def get_edges
    @data["data"]["search"]["edges"]
  end

  def get_issue_count
    @data["data"]["search"]["issueCount"]
  end

  def build_pull_requests_list
    get_edges().map do |edge|
      PullRequest.new(edge["node"]["repository"]["name"],
                      edge["node"]["author"]["login"],
                      edge["node"]["createdAt"],
                      edge["node"]["number"],
                      edge["node"]["url"],
                      edge["node"]["title"],
                      edge["node"]["reviewRequests"]["totalCount"],
                      edge["node"]["reviews"]["totalCount"],
                      edge["node"]["comments"]["totalCount"]
                     )
    end
  end

  def render_badge
    badge = get_issue_count == 0 ? "📭" : "📬"
    puts "#{badge} #{get_issue_count}"
    puts "---"
  end

  def render_header
    puts "Pending review requests 📋 | size=18, href='https://github.com/pulls/review-requested'"
    puts "---"
  end

  def render_list_reviews
    build_pull_requests_list.each do |pr|
      panic_index = calculate_panic_index(pr)
      panic_color, panic_icon = panic_data_for(panic_index)
      title = "#{pr.repo_name} - #{pr.title} | size=16, href=#{pr.url}"
      subtitle = "##{pr.number} opened by #{pr.author_login} #{relative_time(pr.created_at)}"
      puts "#{title}"
      puts "#{subtitle} | #{panic_color}"
      if @stats
         render_stats(pr, panic_index, panic_icon)
      end
    end
  end

  def render_stats(pr, panic_index, panic_icon)
    puts "--Health: | size=16 color='#2196f3'"
    puts "--requests: #{pr.review_requests} | size=12 font=Monaco"
    puts "--reviews: #{pr.reviews} | size=12 font=Monaco"
    puts "--comments: #{pr.comments} | size=12 font=Monaco"
    puts "--index: #{panic_icon} #{panic_index.round(2)} | size=12 font=Monaco"
    puts "--last comment: #PLACEHOLDER FOR LAST COMMENT AGE"
    puts "---" 
  end

  def panic_data_for(panic_index)
    case panic_index
    when 0..0.09
      color = "color='#32CD32'"
      icon = ICONS[0]
    when 0.09..1.5
      color = "color='#ffff00'" 
      icon = ICONS[1]
    when 1.5..2.5
      color = "color='#FF4500'" 
      icon = ICONS[2]
    else
      color = "color='#FF0000'"
      icon = ICONS[3]
    end
    [color, icon]
  end

  def relative_time(from)
    start_time = Date.parse(from).to_time
    diff_seconds = Time.now - start_time
    case diff_seconds
      when 0 .. 59
        "#{(diff_seconds)} seconds ago"
      when 60 .. (3600-1)
        "#{(diff_seconds/60).ceil} minutes ago"
      when 3600 .. (3600*24-1)
        "#{(diff_seconds/3600).ceil} hours ago"
      when (3600*24) .. (3600*24*30) 
        "#{(diff_seconds/(3600*24)).ceil} days ago"
      else
       "on "+start_time.strftime("%B %d, %Y")
    end
  end

  def calculate_panic_index(pr)
    old_seconds = Time.now - Date.parse(pr.created_at).to_time
    week_seconds = 60 * 60 * 24 * 5
    pr_oldness = (old_seconds / week_seconds)
    review_index = pr.reviews > 0 ? (pr.reviews.to_f / pr.review_requests.to_f) : 0.11
    panic_index = pr_oldness * review_index
  end
end