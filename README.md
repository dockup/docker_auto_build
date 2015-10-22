docker_auto_build
=================

It's a simple Sinatra app that listens to events over and HTTP endpoint and
a Github webhook and creates docker images from source code. It also pushes these
images to a docker registry.

## Requirements

1. docker - For building docker images
2. docker-compose - For building complex docker images which need other services to be built

## Installation

    $ gem install docker_auto_build

## Usage

Set the following ENV vars:

```bash
export BUILD_BRANCHES=<comma separated string of branches for which you need docker images to be built when somethig is pushed (when using github webhooks)>
export GITHUB_WEBHOOK_SECRET = <Secret used to configure github webhook (if using github webhooks)>
export GITHUB_OAUTH_TOKEN = <OAuth token which will be used to post comments on PRs (if using github webhooks)>
```

Next, add your(or create a new github user for this) Github oauth token in `~/.netrc` like so:

    machine github.com login <github oauth token> password

Also add the machine's public key to the github account that has access to clone the repositories.

Also if you need to add any `/etc/hosts` entry for your docker registry, don't
forget to do that either.


And run the server

    $ docker_auto_build
