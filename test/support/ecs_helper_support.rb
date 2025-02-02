require 'ostruct'

module ECSHelperSupport
  DEFAULTS = {
    branch: :master,
    version: :test_sha,
    project: "test-pro",
    application: "test-app",
    environment: 'qa'
  }

  def env_prefix
    "#{DEFAULTS[:project]}-#{DEFAULTS[:application]}-#{DEFAULTS[:environment]}"
  end

  def with_command(string, attrs = {})
    new_setup = OpenStruct.new(DEFAULTS.merge(attrs))

    # GEM specific
    ENV["CI_COMMIT_BRANCH"] = new_setup.branch.to_s
    ENV["CI_COMMIT_SHA"] = new_setup.version.to_s
    ENV["PROJECT"] = new_setup.project.to_s
    ENV["APPLICATION"] = new_setup.application.to_s

    # AWS specific
    ENV['AWS_REGION'] ||= AwsSupport.region
    ENV['AWS_ACCESS_KEY_ID'] ||= 'test'
    ENV['AWS_SECRET_ACCESS_KEY'] ||= 'test'

    prev = ARGV.dup
    args = string.split(' ')
    ARGV.replace args
    yield(new_setup)
    ARGV.replace prev
  end
end
