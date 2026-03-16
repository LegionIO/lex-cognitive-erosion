# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_erosion/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-erosion'
  spec.version       = Legion::Extensions::CognitiveErosion::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Erosion'
  spec.description   = 'Models gradual belief reshaping through persistent exposure — like water shaping stone. ' \
                       'Erosion channels form, resistance varies, canyons emerge from deep grooves.'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-erosion'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-erosion'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-erosion'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-erosion'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-erosion/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
