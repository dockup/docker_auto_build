docker_auto_build
=================

It's a simple Sinatra app that listens to events over and HTTP endpoint and
a Github webhook and creates docker images from source code. It also pushes these
images to a docker registry.

## Requirements

1. ruby 2.1 or later - For running docker_auto_build
2. docker - For building docker images
3. docker-compose - For building complex docker images which need other services to be built


## Configuration

Add your(or create a new github user for this) Github oauth token in `~/.netrc` like so:

    machine github.com login <github oauth token> password

Also add the machine's public key to the github account that has access to clone the repositories.

Also if you need to add any `/etc/hosts` entry for your docker registry, don't
forget to do that either.

### Automated builds using Github Webhooks

First, set up a Github webhook by going to the settings page of the repositories
for which you want to enable automated image builds:

![github-webhook-configuration](https://s3-ap-southeast-1.amazonaws.com/uploads-ap.hipchat.com/39906/538857/V2BN0dDNhrTnuRO/upload.png)

Remember the secret that you entered, we'll need it later.

Also, if you want only specific branches of a repository to be built, you
can add a file to your project repository root named `docker_auto_build.yml`
containing the following:

```yaml
branches: ['master', 'development']
```

### Environment Variables

Set the following ENV variables before running docker_auto_build :

```bash
export GITHUB_WEBHOOK_SECRET = <Secret used when configuring github webhook (if using github webhooks)>
export GITHUB_OAUTH_TOKEN = <OAuth token of Github user (if using github webhooks)>
export DOCKER_REGISTRY_HOST = <Docker registry host to with images are pushed>
export PORT= <Override default port of docker_auto_build (8000)>
```

## Usage

    $ git clone https://github.com/code-mancers/docker_auto_build.git
    $ cd docker_auto_build
    $ bundle install
    $ ruby exe/docker_auto_build

Send an API request to `localhost:8000/build` like so:

```
curl -XPOST  -d '{"repository_url":"https://github.com/repo/project.git","branch":"master","image_name":"my.dockerhub:5000/image_name:tag"}' -H "Content-Type: application/json" localhost:8000/build
```

## License

MIT
