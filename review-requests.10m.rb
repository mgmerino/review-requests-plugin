#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# <bitbar.title>Github review requests</bitbar.title>
# <bitbar.desc>Shows a list of PRs that need to be reviewed</bitbar.desc>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>Manuel Gonzalez</bitbar.author>
# <bitbar.author.github>mgmerino</bitbar.author.github>
# <bitbar.dependencies>ruby faraday json yaml time</bitbar.dependencies>

require "faraday"
require "json"
require "yaml"
require "time"

require_relative "lib/graphql_client"
require_relative "lib/ui_builder"
require_relative "lib/time_helper"

config = YAML.load_file(File.join(__dir__, 'lib/config.yml'))
github_handler = config["github_handler"]
github_org = config["github_org"]
blacklisted_prs = config["blacklisted_prs"]

graphql_query = "{\r\n  search(query: \"org:#{github_org} is:pr is:open review-requested:#{github_handler}\", type: ISSUE, last: 10) {\r\n    issueCount\r\n    edges {\r\n      node {\r\n        ... on PullRequest {\r\n          repository {\r\n            name\r\n          }\r\n          author {\r\n            login\r\n          }\r\n          reviews{\r\n            totalCount\r\n          }\r\n          reviewRequests{\r\n            totalCount\r\n          }\r\n          comments{\r\n            totalCount\r\n          }\r\n          createdAt\r\n          number\r\n          url\r\n          title\r\n        }\r\n      }\r\n    }\r\n  }\r\n}"
ICONS = ["🥬", "🔆", "✴️", "🚩"]

client = GraphqlClient.new(token: config["github_token"])
data = client.do_query(graphql_query)

UIBuilder.new(JSON.parse(data), blacklisted_prs, true).do_render
