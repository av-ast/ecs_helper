# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-ecs'
require 'aws-sdk-ecr'

class ECSHelper::Command::BuildAndPushTest < Minitest::Test
  def test_build_and_push_with_cache
    command = 'build_and_push --image=web --cache'
    cache = true

    with_command(command) do |setup|
      repo = prepare_data(setup, :web)

      stub_auth()
      stub_pull(repo[:repository_uri])
      stub_build(repo[:repository_uri], setup.version, cache)
      stub_push(repo[:repository_uri], setup.version)

      helper = ECSHelper.new
      helper.run
    end
  end

  def test_build_and_push_without_cache
    command = 'build_and_push --image=web'
    cache = false

    with_command(command) do |setup|
      repo = prepare_data(setup, :web)

      stub_auth()
      stub_build(repo[:repository_uri], setup.version, cache)
      stub_push(repo[:repository_uri], setup.version)

      helper = ECSHelper.new
      helper.run
    end
  end

  def test_build_and_push_nginx
    command = 'build_and_push --image=nginx'
    cache = false

    with_command(command) do |setup|
      repo = prepare_data(setup, :nginx)

      stub_auth()
      stub_build(repo[:repository_uri], setup.version, cache)
      stub_push(repo[:repository_uri], setup.version)

      helper = ECSHelper.new
      helper.run
    end
  end

  private

  def prepare_data(setup, repo_key = :web)
    names = {
      web: "#{setup.project}-#{setup.application}-web",
      only_web: 'web',
      nginx: "#{setup.project}-#{setup.application}-nginx",
      some_other_nginx_repo: 'some_other_project-nginx',
    }

    repos = names.each_with_object({}) do |(key, repo_name), hash|
      hash[key] = AwsSupport.repository(repo_name)
    end

    stub_repositories(repos.values)
    repos[repo_key]
  end
end
