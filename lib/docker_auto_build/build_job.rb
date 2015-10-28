require 'sucker_punch'
require 'securerandom'
require 'docker_auto_build/command'

module DockerAutoBuild
  class BuildJob
    include SuckerPunch::Job

    def perform(repository_url:, branch: 'master', config_file: 'docker_auto_build.yml', image_name:, callbacks: [])
      @branch = branch
      @repository_url = repository_url
      @random_directory_name = SecureRandom.hex
      @config_file = config_file
      @image_name = image_name

      clone_repository
      docker_build
      docker_push
      docker_delete_image

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

    def clone_repository
      git_clone_command = Command.run(command: ['git', 'clone', "--branch=#{@branch}", '--depth=1', @repository_url, @random_directory_name])
      raise "Cannot clone repositroy: #{@repository_url}, branch: #{@branch}" unless git_clone_command.success?
    end

    def docker_build
      Dir.chdir @random_directory_name do
        if File.exist?(@config_file)
          #@config = YAML.load_file(@config_file) || {}
          #build_from_config
          puts "Not yet!"
        else
          docker_build_command = Command.run(command: ['docker', 'build', '-t', @image_name, '.'])
          unless docker_build_command.success?
            raise "Cannot build docker image using docker build command. Logs: #{docker_build_command.output}"
          end
        end
      end
    end

    #def build_from_config
      #file = @config['file'] || 'docker-compose.yml'
      #command = @config['command']
      #commit_service = @config['commit']

      #up_command = Command.run(command: ['docker-compose', '-f', file, 'up', '-d'])
      #raise "Cannot start services using docker-compose up. Logs: #{up_command.output}" unless up_command.success?
      #command.each do |service, command|
        #run_command = Command.run(command: ['docker-compose', '-f', file, 'run', service, command.split(' ').each(&:strip)])
        #raise "Cannot run command #{command} in service #{service}. Log: #{run_command.output}" unless run_command.success?
      #end
      #Command.run(command: ['docker-compose', '-f', file, 'stop'])
      #ps_command = Command.run(command: ["docker-compose", '-f', file, "ps", "-q", commit_service])
      #container_id = ps_command.output.strip
      #Command.run(command: ['docker', 'commit', container_id, @image_name])
      #Command.run(command: ['docker-compose', '-f', file, 'rm', '-v'])
    #end

    def docker_push
      push_command = Command.run(command: ['docker', 'push', @image_name])
      raise "Cannot push docker image #{@image_name}. Logs: #{push_command.output}"
    end

    def docker_delete_image
      Command.run(command: ['docker', 'rmi', '-f', @image_name])
    end
  end
end
