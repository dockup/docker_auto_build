require 'sucker_punch'
require 'securerandom'
require 'docker_auto_build/command'

module DockerAutoBuild
  class BuildJob
    include SuckerPunch::Job

    def perform(repository_url:, branch: 'master', config_file: 'docker_auto_build.yml', image_name: nil, callbacks: [])
      @branch = branch
      @repository_url = repository_url
      @random_directory_name = SecureRandom.hex
      @config_file = config_file
      @image_name = image_name || get_default_image_name

      clone_repository
      docker_build
      docker_push
      docker_delete_image

      puts "Successfully built and pushed docker image #{@image_name}"
      callbacks.each{|c| c.build_success(@repository_url, @branch, @image_name)}
    rescue StandardError => e
      reason = e.message
      puts "Cannot build image for #{@repository_url} : #{@branch}. Reason: #{reason}"
      puts e.backtrace
      callbacks.each{|c| c.build_failure(@repository_url, @branch, reason)}
    ensure
      FileUtils.rm_rf @random_directory_name
    end

    private

    def get_default_image_name
      repository_name = @repository_url.match(/.*github.com\/(.*)\/(.*).git/)[2]
      "#{ENV['DOCKER_REGISTRY_HOST']}/#{repository_name}:#{@branch}"
    end

    def clone_repository
      git_clone_command = Command.run(command: ['git', 'clone', "--branch=#{@branch}", '--depth=1', @repository_url, @random_directory_name])
      raise "Cannot clone repositroy: #{@repository_url}, branch: #{@branch}" unless git_clone_command.success?
    end

    def docker_build
      Dir.chdir @random_directory_name do
        docker_build_command = Command.run(command: ['docker', 'build', '-t', @image_name, '.'])
        unless docker_build_command.success?
          raise "Cannot build docker image using docker build command. Logs: #{docker_build_command.output}"
        end
      end
    end

    def docker_push
      puts "Pushing image #{@image_name.inspect}"
      push_command = Command.run(command: ['docker', 'push', @image_name])
      raise "Cannot push docker image #{@image_name}. Logs: #{push_command.output}" unless push_command.success?
    end

    def docker_delete_image
      Command.run(command: ['docker', 'rmi', '-f', @image_name])
    end
  end
end
