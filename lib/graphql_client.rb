class GraphqlClient
  def initialize(token:)
    @token = token
    @base_url = "https://api.github.com"
  end

  def do_query(query)
    conn = Faraday.new(:url => @base_url)
    conn.authorization :Bearer, @token
    res = conn.post do |req|
      req.url '/graphql'
      req.headers['Content-Type'] = 'application/json'
      req.body = {"query": query}.to_json
    end
    res.body
  end
end
