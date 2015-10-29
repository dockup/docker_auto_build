require 'yaml'
require 'httparty'
require 'sucker_punch'

module DockerAutoBuild
  class GithubWebhookHandlerJob
    include SuckerPunch::Job

    def perform(payload)
      raise "Github Webhook event doesn't seem to be a push event" unless payload['pusher']
      raise "Commits are empty for this push" if payload['commits'].empty?

      repository_url = payload['repositroy']['clone_url']
      branch = payload['ref'].match('refs\/heads\/(.*)')[1]
      config_file_url = github_content_url(branch, 'docker_auto_build.yml')
      config = read_config_from_github(config_file_url)
      build_branches = config['branches']
      raise "#{branch} is not one of #{build_branches.to_s}" unless build_branches.include?(branch)

      BuildJob.new.async.perform(
        repository_url: repository_url,
        branch: branch
      )
    rescue StandardError => e
      reason = e.message
      puts "Cannot handle github webhook payload for #{repository_url} : #{branch}. Reason: #{reason}"
      puts e.backtrace
    end

    private

    def github_content_url(branch, path)
      base_url = URITemplate.new(payload['repositroy']['contents_url']).expand(path: path)
      "#{base_url}?ref=#{branch}"
    end

    def read_config_from_github(config_file_url)
      response = HTTParty.get(config_file_url, headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "token #{ENV['GITHUB_OAUTH_TOKEN']}",
        'Accept' => 'application/vnd.github.v3.raw',
        'User-Agent' => 'docker_auto_build'
      })
      raise "Cannot fetch config file from Github using URL: #{config_file_url}" if response.code != 200

      YAML.load response.to_s
    end
  end
end
