require 'httparty'
require 'json'

module DockerAutoBuild
  class WebhookCallback
    def initialize(post_url)
      @post_url = post_url
    end

    def build_success(repository_url, branch, docker_image_tag)
      body = {
        repository_url: repository_url,
        branch: branch,
        docker_image_tag: docker_image_tag,
        status: :build_success
      }
      HTTParty.post(@post_url, body: body.to_json, headers: {'Content-Type' => 'application/json'})
    end

    def build_failure(repository_url, branch, reason)
      body = {
        repository_url: repository_url,
        branch: branch,
        reason: reason,
        status: :build_failure
      }
      HTTParty.post(@post_url, body: body.to_json, headers: {'Content-Type' => 'application/json'})
    end
  end
end
