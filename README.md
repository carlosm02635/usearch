# USearch

USearch provides some model scopes/methods useful to search and sort your active record data.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

### - `search all scope`:

Include the concern in the model you want tu use the scope:
```
include Usearch::SearchAllScope
```
then you can use the `search_all_scope_fields` method to specify the fields you want to include in your query, `search_all_scope_fields` should include existent attributes for the model.
```
search_all_scope_fields :field_one, field_two, ...
```
it also accepts fields from joined tables, we can achieve that using an array with the name of the joined table as first element
and the name of the field as second, example:
```
search_all_scope_fields :field_one, :field_two, [:joined_table_name, :joined_table_field_name], 
[:joined_table_name, :joined_table_field_name] ...
```
Then you can use the scope for the model:
```
ModelName.search_all(query: 'a string value')
```
full example:
```
class User < ApplicationRecord
  include Usearch::SearchAllScopeConcern

  has_one :address

  search_all_scope_fields :name, :last_name, [:address, :city]
end
```
In that example if we use `User.search_all(query: 'james')` it will return all the records that have a concidence with the word `james`, checking in `users.name`, `users.last_name` and `adresses.city`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carlosm02635/usearch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/usearch/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Usearch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/usearch/blob/main/CODE_OF_CONDUCT.md).
