build:
    bundle install

test:
    bundle exec rake test

check:
    bundle exec rubocop
    for f in lib/identisure/*.rb; do ruby -wc "$f" > /dev/null || exit 1; done

publish:
    gem build identisure-client.gemspec
    gem push identisure-client-*.gem

gen-doc:
    bundle exec yard doc --output-dir docs --readme README.md 'lib/**/*.rb'
