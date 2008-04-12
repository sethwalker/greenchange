= DslAccessor

This gem gives hybrid accessor class methods to classes by DSL like definition,
here hybrid means getter and setter. The accessor method acts as getter method
if no arguments given, otherwise it acts as setter one with the arguments.


=== Usage

  class Foo
    dsl_accessor "<METHOD NAME>"
  end


=== Example

  class Foo
    dsl_accessor :greeting
  end

  This code gives 'greeting' class method to Foo class.

  Foo.greeting                 # means getter, and the default value is nil.
  => nil

  Foo.greeting "I'm Foo."      # means setter with given arguments
  => "I'm Foo."

  Foo.greeting
  => "I'm Foo."


=== Difference

I'm convinced that you want to propose me to use 'cattr_accessor'.
Although the difference is just whether we needs '=' operation or not,
it makes a large different on class definition especially subclass.

  class Foo
    cattr_accessor :greeting
  end

  class Bar < Foo
    self.greeting = "I'm bar."
  end

We must write redundant code represented by "self." to distinguish
a local variable and a class method when we use 'cattr_accessor'.
This is ugly and boring work.

  class Foo
    dsl_accessor :greeting
  end

  class Bar < Foo
    greeting "I'm bar."
  end

There are no longer redundant prefix code like "self." and "set_".
Don't you like this dsl-like coding with simple declaration?


=== Special Options

'dsl_accessor' method can take two options, those are :writer and :default.
"writer" option means callback method used when setter is executed.
"default" option means default static value or proc that creates some value.

  class PseudoAR
    dsl_accessor :primary_key, :default=>"id", :writer=>proc{|value| value.to_s}
    dsl_accessor :table_name,  :default=>proc{|klass| klass.name.demodulize.underscore.pluralize}
  end

  class Item < PseudoAR
  end

  class User < PseudoAR
    primary_key :user_code
    table_name  :user_table
  end
  
  Item.primary_key  # => "id"
  Item.table_name   # => "items"
  User.primary_key  # => "user_code"
  User.table_name   # => :user_table

Note that "User.primary_key" return a String by setter proc.


=== Install

  gem install dsl_accessor

=== Author

Code: Maiha <anna@wota.jp>
Gem: Alex Wayne <rubyonrails@beautifulpixel.com>