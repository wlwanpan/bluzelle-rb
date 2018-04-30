
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "swarmclient/version"

Gem::Specification.new do |spec|
  spec.name          = "swarmclient"
  spec.version       = Swarmclient::VERSION
  spec.authors       = ["Warren"]
  spec.email         = ["wlwanpan@uwaterloo.ca"]

  spec.summary       = %q{A gem for the bluzele SwarmDB}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "faye-websocket", "~> 0.10"
  spec.add_development_dependency "eventmachine", "~> 1.2"
  spec.add_development_dependency "json", "~> 2.1"
  spec.add_development_dependency "websocket-client-simple", "~> 0.3"
end
