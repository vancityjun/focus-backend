guard :rspec, cmd: 'spring rspec -f doc' do
  # Auto test runner for changed core files
  # run controller concerns
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/.+_helper\.rb$}) { 'spec' }
  watch(%r{^app/controllers/(.+)\.rb$}) { |m| ["spec/controllers/#{m[1]}_spec.rb"] }

  # run model tests
  watch(%r{^app/models/(.+)\.rb$}) { |m| ["spec/models/#{m[1]}_spec.rb", "spec/models/#{m[1]}"] }
  # run graphql tests
  watch(%r{^app/graphql/(.+)\.rb$}) { |m| ["spec/graphql/#{m[1]}_spec.rb"] }

  # run factory tests
  watch(%r{^spec/factories.rb}) { 'spec/factories_spec.rb' }
  watch(%r{^spec/factories/(.+)\.rb$}) { 'spec/factories_spec.rb' }
end

guard 'spring', bundler: true do
  watch('Gemfile.lock')
  watch(%r{^config/})
end
