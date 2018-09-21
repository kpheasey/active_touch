# ActiveTouch
A more robust touch for ActiveRecord associations.
- Touch specific associations when specific attributes change
- Call an optional method on those touched records
- Perform the touch synchronously or asynchronously

## Installation

Add the gem to your Gemfile:

```ruby
gem 'active_touch', '~> 4.0'
```

Then run the installer:

```sh
rails g active_touch:install
```

## Usage

Basic touch that runs `after_commit`.  This will update the association's updated_at.

```ruby
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations
end
```

NOTE: It doesn't matter what type of association is given.  The association can even reference an instance method that returns an `ActiveRecord` collection or record.


### Attribute specific touches

To only call the touch when specific attributes are changed, supply an array of attributes with `:watch`.  The following example will only touch `:relations` when `:name` or `:code` changes.

```ruby
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations, watch: [:name, :code]
end
```


### After Touch Callback

To call a method on the touched records, use `:after_touch`.  The following example will call `:do_something` on the associated records after a tocuh.

```ruby
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations, after_touch: :do_something
end
```

NOTE: The `after_touch` method must be an instance method defined on the associated Class.


### Asynchronous touch

The touch can also be queued and run in the background using `ActiveJob` by setting the `:async` flag.  The following example will run a touch in the background.

```ruby
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations, async: true
end
```

NOTE: The default is `async: false`


## Options

There are a few options that you can change by updating `config/initializers/active_touch.rb`.

- `async`: Default to asynchronous touches
- `ignored_attributes`: When no `watch` argument is supplied, all attribute changes can trigger a touch.  Define a default list of ignored attributes here.  Default is `[:updated_a]t`.
- `queue`: Specify which queue to put asynchronous jobs in.
- `timestamp_attribute`: The timestamp attribute that is updated by a touch, default is  `:updated_at`.  You can set this to `nil` if you don't want to update any timestamp.
