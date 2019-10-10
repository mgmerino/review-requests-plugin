# Review requests counter for bitbar

This is a simple [bitbar](https://github.com/matryer/bitbar) plugin, inspired by [this one](https://github.com/matryer/bitbar-plugins/blob/master/Dev/GitHub/github-review-requests.5m.py) which is written in python.

This has been rewritten in Ruby and enhanced with some more superfluous data about the PR's and loaded of emojis for no particular reason 🤖.

It uses Faraday as a http client to send a graphql query into github endpoint to retrieve the collection of PR reviews assigned to you.

## Dependencies
This plugin needs the following gems installed under your default system path/owner when running ruby scripts.

- faraday
- json
- yaml

## Installation

Clone the repo somewhere in your path. Create a yml file containig the following keys:

```yml
github_handler: your_github_handler
github_org: your_organization
github_token: your-github-api-token # generate your own GitHub API token
blacklisted_prs: [123, 187] # optional blacklisted PR's
```

Generate your personal access token: [https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line)

Save it under `lib` folder.

Then make a symlink into your bitbar plugins folder (i.e: ~/bitbar-plugins).

```bash
ln -s review-requests-plugin/review-requests.10m.rb ~/bitbar-plugins/
```

## Contribute

Feel free to ask for features or contribute if you miss something!
