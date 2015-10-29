require 'sinatra'
require 'json'
require 'uri_template'
require 'docker_auto_build/build_job'
require 'docker_auto_build/github_webhook_handler_job'
require 'docker_auto_build/webhook_callback'

module DockerAutoBuild
  BUILD_BRANCHES = ENV['BUILD_BRANCHES'].to_s.split(',').collect(&:strip)
  class App < Sinatra::Base
    set :port, 8000
    set :bind, '0.0.0.0'

    post '/build' do
      content_type :json
      json = JSON.parse(request.body.read)
      post_url = json['callback_url']

      BuildJob.new.async.perform(
        repository_url: json['repository_url'],
        branch: json['branch'],
        image_name: json['image_name'],
        callbacks: (post_url ? [WebhookCallback.new(post_url)] : [])
      )
    end

    post '/gh-webhook' do
      payload_body = request.body.read
      verify_signature(payload_body)
      payload = JSON.parse(payload_body)

      GithubWebhookHandlerJob.new.async.perform(payload)
    end

    private

    def verify_signature(payload_body)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['GITHUB_WEBHOOK_SECRET'], payload_body)
      return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    end
  end
end

DockerAutoBuild::App.run!
