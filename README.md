rails_utils
================
A collection of some Rails utilities & custom Gems. These are little go-to's that I wrote when I noticed I was constantly writing the same report 
## klass_factory
The wait is over! KlassFactory will formulate deeply nested objects into full-fledged ruby classes. This class acts as an anonymous class generator for arbitrary hashes and arrays. 
turn this:
```ruby
{:foo => "bar", :baz => { :first => "A", :second => [1,2,{:third => "B"}]}}
``` 
into
```ruby
<K:0x00000002735080 @foo="bar", @baz=<Baz:0x000000027346a8 @first="A", @second=[1, 2, <Second:0x00000002733500 @third="B">]>> 
```
KlassFactory works by implementing an already defined class instance and adding class variables by attribute key. For keyed nested objects, KlassFactory creates defined classes based from the keys. 

This is useful for API calls when revieving complex, or lenghty objects that either may vary, and / or you're too lazy to create attribute mappers for your classes.

### Usage
Using this class is simple. Simply define your container class and call the static method `KlassFactory.init` with the attributes passed in:
```ruby
class K
  def initialize attrs = {}
    instance = KlassFactory.init self, attrs
    return instance
  end
end
# initialize above hash by:
instance_k = K.new {:foo => "bar", :baz => { :first => "A", :second => [1,2,{:third => "B"}]}}
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

## Yaapi - Yet another API 
This is the seed of a gem that I will extend. There were some aspects of ActiveResource that don't play nice with models sometimes. I don't like how ActiveResource assigns your params as attributes. Actually, I don't like how Ruby obscures attribute access. 
Yaapi, at its core currently uses HTTParty to facilitate api requests but I may integrate NET::HTTP instead (utilizing the net-http-cheat-sheet: https://github.com/augustl/net-http-cheat-sheet/blob/master/file_upload_html_style.rb).
Additionally, I will be refactoring this into a Gem, providing a depedency on webmocks for method stubs.

### Installation
Place the yaapi.rb file in your project/lib folder. 
Run the following from yoiur project/config/initializers folder:
```bash
echo "require './lib/yaapi.rb'" >> yaapi.rb
```

### Implementation
Your class will inherit the Base class of the yaapi module:
```ruby
class MyClass < Yaapi::Base
```
Set up your accessors, initializers as you normally would. 
You will need to provide a class method "path" which contains the configuration options for Yaapi.

For RESTful Getters and Setters, the api expects an "id" parameter to be passed in. Set this as you would a typical Rails route.

See the example below:
```ruby
def self.path {
    :url => "http://your_endpoint_root.com"
    :fetch => "/path/to/resource/:id
    :fetch_all => "/path/to/resource"
    :create => "/path/to/resource" 
    :put => "/path/to/resource/:id"
    :delete => "/path/to/resource/:id"
  }
end
```
This is all the configuration needed. A few notes on setting the path method:

* Not all paths are required. Specify only the paths you need (There is no :only restriction like in rails routes)
* The math method assumes interaction with a RESTful api. Additionally, Yaapi (at this time) only inserts one dynamic element (:id) in your route.
  * for static routes without dynamic elements, you can utilize :fetch_all
* :fetch_all may be intitialized with or without an id paramter.

### Methods
The static Restful methods are:

#### get all id (optional) 
Returns a collection of objects. The id paramater is supplied when the colleciton is a child of an object (e.g. /customers/:id/invoices)

#### get id
Returns an instance of an object

#### update_existing options
Expects a hash of attributes to be updated. Options hash must define an :id field. Returns instance of updated object

#### create_new options
Expects options for  the object to create. Returns an instance of newly created object.

#### delete_existing id
Returns an empty instance of object (see below)

### Errors
An :errors collection will be set for any http response not in 200, 201, 202, 203, 204, 205. Either the server response or any response object set by the endpoint will be set as member in the collection.

Any error or error object set by the endpoint returning http success (2xx) will be interepreted as a valid call by yaapi and the results will be set accordingly.
These situations must be handled by the derived class in the initializer.

### Sample Controller

Following is a sample controller utilizing yapi:

```ruby
class WidgetsController < ApplicationController
  respond_to :json
  def index
    @widgets = Widget.get_all params[:id] 
    respond_to do |format| 
      format.json { render :json => @widget, :status => :ok}
    end
  end

  def show
    @widget = Widget.get params[:id]
    respond_to do |format|
      format.json { render :json => @widget, :status => :ok}
    end
  end
  
  def create
    @widget = Widget.create_new params[:widget]
    respond_to do |format|
      if @widget.respond_to? :errors
        format.json { render :json => @widget.errors, :status => :unprocessable_entity }
      else
        format.json { render :json => @widget, :status => :ok }
      end
    end
  end
  
  def update
    @widget = Widget.update_existing params[:widget]
    respond_to do |format|
      if @widget.respond_to? :errors
        format.json { render :json => @widget.errors, :status => :unprocessable_entity }
      else
        format.json { render :json => @widget, :status => :ok }
      end
    end
  end
  
  def destroy
    @widget = Widget.delete_existing params[:id]
    respond_to do |format|
      if widget.respond_to? :errors
        format.json { render :json => widget.errors, :status => :unprocessable_entity }
      else widget.respond_to? :errors
        format.json { head :ok }
      end
    end
  end
```



