require 'httparty'
require 'json'

module DockerAutoBuild
  class GithubCommentCallback
    def initialize(comments_url)
      @comments_url = comments_url
    end

    def build_success(repository_url, branch, docker_image_tag)
      body = "Docker image: #{docker_image_tag}"
      HTTParty.post(@comments_url, body: {body: body}.to_json, headers: {
        'Authorization' => "token #{ENV['GITHUB_OAUTH_TOKEN']}",
        'User-Agent' => 'docker_auto_build' #Mandatory field, just passing random value
      })
    end

    def build_failure(repository_url, branch, reason)
      body = "Could not build docker image. Reason: #{reason}."
      HTTParty.post(@comments_url, body: {body: body}.to_json, headers: {
        'Authorization' => "token #{ENV['GITHUB_OAUTH_TOKEN']}",
        'User-Agent' => 'docker_auto_build' #Mandatory field, just passing random value
      })
    end
  end
end
