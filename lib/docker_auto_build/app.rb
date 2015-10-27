require 'sinatra'
require 'json'
require 'docker_auto_build/build_job'
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
        callbacks: (post_url ? [WebhookCallback.new(post_url)] : [])
      )
    end

    post '/gh-webhook' do
      payload_body = request.body.read
      verify_signature(payload_body)
      payload = JSON.parse(payload_body)

      if payload['pusher']
        return if payload['commits'].empty?
        return unless BUILD_BRANCHES.include? branch

        BuildJob.new.async.perform(
          repository_url: repository_url,
          branch: branch
        )
      end
    end

    def verify_signature(payload_body)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['GITHUB_WEBHOOK_SECRET'], payload_body)
      return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    end
  end
end

DockerAutoBuild::App.run!
