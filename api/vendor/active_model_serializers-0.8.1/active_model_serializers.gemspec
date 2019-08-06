# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "active_model_serializers"
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jos\u{e9} Valim", "Yehuda Katz"]
  s.date = "2014-01-31"
  s.description = "Making it easy to serialize models for client-side use"
  s.email = ["jose.valim@gmail.com", "wycats@gmail.com"]
  s.files = [".gitignore", ".travis.yml", "CHANGELOG.md", "CONTRIBUTING.md", "DESIGN.textile", "Gemfile", "Gemfile.edge", "MIT-LICENSE.txt", "README.md", "Rakefile", "active_model_serializers.gemspec", "bench/perf.rb", "cruft.md", "lib/action_controller/serialization.rb", "lib/active_model/array_serializer.rb", "lib/active_model/serializable.rb", "lib/active_model/serializer.rb", "lib/active_model/serializer/associations.rb", "lib/active_model/serializer/caching.rb", "lib/active_model/serializer/version.rb", "lib/active_model_serializers.rb", "lib/active_record/serializer_override.rb", "lib/generators/resource_override.rb", "lib/generators/serializer/USAGE", "lib/generators/serializer/serializer_generator.rb", "lib/generators/serializer/templates/serializer.rb", "test/array_serializer_test.rb", "test/association_test.rb", "test/caching_test.rb", "test/generators_test.rb", "test/no_serialization_scope_test.rb", "test/serialization_scope_name_test.rb", "test/serialization_test.rb", "test/serializer_support_test.rb", "test/serializer_test.rb", "test/test_fakes.rb", "test/test_helper.rb"]
  s.homepage = "https://github.com/rails-api/active_model_serializers"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.0.3"
  s.summary = "Bringing consistency and object orientation to model serialization. Works great for client-side MVC frameworks!"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, [">= 3.0"])
      s.add_development_dependency(%q<rails>, [">= 3.0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<coveralls>, [">= 0"])
    else
      s.add_dependency(%q<activemodel>, [">= 3.0"])
      s.add_dependency(%q<rails>, [">= 3.0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<coveralls>, [">= 0"])
    end
  else
    s.add_dependency(%q<activemodel>, [">= 3.0"])
    s.add_dependency(%q<rails>, [">= 3.0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<coveralls>, [">= 0"])
  end
end
