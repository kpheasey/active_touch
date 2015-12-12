# ActiveTouch
A more robust touch for ActiveRecord associations.
- Touch specific associations when specific attributes change
- Call an optional method on those touched records
- Perform the touch synchronously or asynchronously

## Installation

Add the gem to your Gemfile:

```
gem 'active_job', '~> 1.0.0'
```

## Usage

Basic touch that runs `after_commit`.  This will update the association's updated_at.

```
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations
end
```

NOTE: It doesn't matter what type of association is given.  The association can even reference an instance method that returns an `ActiveRecord` collection or record.

To only call the touch when specific attributes are changed, supply an array of attributes with `:watch`.  The following example will only touch `:relations` when `:name` or `:code` changes.

```
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations, watch: [:name, :code]
end
```

To call a method on the touched records, use `:after_touch`.  The following example will call `:do_something` on the associated records after a tocuh.

```
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations, after_touch: :do_something
end
```

NOTE: The `after_touch` method must be an instance method defined on the associated Class.

The touch can also be queued and run in the background using `ActiveJob` by setting the `:async` flag.  The following example will run a touch in the background.

```
class Model < ActiveRecord::Base
  has_many :relations

  touch :relations, async: true
end
```

NOTE: The default is `async: false`
