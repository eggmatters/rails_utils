rails_utils
================
A collection of some Rails utilities & custom Gems. These are little go-to's that I wrote when I noticed I was constantly writing the same report 
## klass_factory
The wait is over! KlassFactory will formulate deeply nested objects into full-fledged ruby classes. This class acts as an anonymous class generator for arbitrary hashes and arrays. 
turn this:
```ruby
{:foo= > "bar", :baz => { :first => "A", :second => [1,2,{:third => "B"}]}}
``` 
into
```ruby
<K:0x000000033158c8 @foo="bar", @baz=<Baz:0x00000003315120 @first="A", @second=[<Second:0x000000033146a8>,<Second:0x00000003314220>, <Second:0x000000032fbdb0 @third="B">]
```
KlassFactory works by implementing an already defined class instance and adding class variables by attribute key. For keyed nested objects, KlassFactory creates defined classes based from the keys. 

This is useful for API calls when revieving complex, or lenghty objects that either may vary, and / or you're too lazy to create attribute mappers for your classes.

### Usage
Using this class is simple. Simply define your container class and call the static method `KlassFactory.init` with the attributes passed in:
```ruby
class K
  def initialize attrs = {}
    intance = KlassFactory.init self, attrs
    return instance
  end
end
# initialize above hash by:
instance_k = K.new {:foo= > "bar", :baz => { :first => "A", :second => [1,2,{:third => "B"}]}}
```

You may wish to validate and groom your attributes before calling KlassFactory. 

## Recursive Symbolize Keys
This is a useful script for console testing as well as ensuring hashes are symbolized before operating on them. Ruby allows you to convert a hash key identifier to a symbol but it will only work on the top level of a hash. Consider:
```ruby
> myhash = {"chow"=>"mein", "recipe"=> { "ingredients" => [ "noodles","sauce"], "step_one" => "get noodles" } }
> myhash.symbolize_keys!
 => {:chow=>"mein", :recipe=>{"ingredients"=>["noodles", "sauce"], "step_one"=>"get noodles"}}
 ```
 the keys in the recipe hash are not symbolized.
 Enter rsk!
 ```ruby
 > require '~/rails_utils/recursive_symbolize_keys.rb'
 => true 
> rsk! myhash
 => {:chow=>"mein", :recipe=>{:ingredients=>["noodles", "sauce"], :step_one=>"get noodles"}} 
  ```
