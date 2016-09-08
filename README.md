# Quixir: Pure Elixir Property-based Testing [![Build Status](https://travis-ci.org/pragdave/quixir.svg?branch=master)](https://travis-ci.org/pragdave/quixir)

[Property-based
testing](http://blog.jessitron.com/2013/04/property-based-testing-what-is-it.html)
is a technique for testing your code by considering general properties
of the functions you write. Rather that using explicit values in your
tests, you instead try to define the types of the values to feed it,
and the properties of the results produced.

For example, given a list, you know that reversing it should produce a
list with the same number of elements. You can specify this in Quixir
like this:

~~~ elixir
ptest some_list: list do
  reversed = my_reverse(some_list)
  assert length(reversed) == length(some_list)
end
~~~

This says that we're going to run a property test. It will run the
block with a large number of different lists, and inside the block you
can refer to each list as `some_list`. Inside the block, we have
normal ExUnit test code: we produce a reversed copy of the list, then
assert its length is the same as the original.

But what list do we actually pass in? The simple answer is "lots of
them." In this particular case, we'll generate a hundred lists. These
will vary in length, and vary in content, but we guarantee to include
at least one empty list and one list containing a single element (as these
are both common boundary cases that can break code). The overall test
passes if the assertion it contains is true for all these lists.

## What's The Big Deal?

Property-based testing delivers two major benefits.

First, it tests things you might not have considered when writing
tests manually. It can run tens or hundreds of thousands of tests,
using a range of inputs, and verify that the properties you specify
are honored.

Second, and more important, writing property-based tests forces you to
think about the _invariants_ in your code: _what should be true no
matter what I feed this function?_ And invariants are the cornerstone
of all good design. Most likely you use them every day, but they're
often implicit in what you do. Property-based testing surfaces these
invariants—they will drive (and improve) the design of your code.

’nuf hype. Here are the details. But first…

### Alternatives

For a different approach, see
[ExCheck](https://github.com/parroty/excheck), built on
[triq](https://github.com/krestenkrab/triq).

## Installation

~~~ elixir
def deps do
  [
    ...
    { :quixir, "~> 0.1", only: :test },
    ...
  ]
end
~~~

## Including in Tests

Quixir tests run inside regular ExUnit tests, and can take advantage
of all the ExUnit features, including tagging, setup, and `describe`
blocks.

Here's a full test file:

~~~ elixir
defmodule TestReverse do
  use ExUnit.Case
  use Quixir

  import MyList, only: [ reverse: 1 ]

  test "a reversed list has the same length as the original" do
    ptest original: list do
      reversed = reverse(original)
      assert length(reversed) == length(original)
    end
  end

  test "reversing a list twice returns the original" do
    ptest original: list do
      new_list = original |> reverse |> reverse
      assert new_list == original
    end
  end

  test "reversing a list of length 1 does nothing" do
    ptest original: list(length: 1) do
      assert reverse(original) == original
    end
  end

  test "reversing a list of length 2 swaps the elements" do
    ptest original: list(length: 2) do
      [ b, a ] = reverse(original)
      assert [ a, b ] == original
    end
  end

  test "reversing a list of length 3 swaps the extremes" do
    ptest original: list(length: 3) do
      [ c, b, a ] = reverse(original)
      assert [ a, b, c ] == original
    end
  end
end
~~~

## Anatomy of a Property Test

The general form of a property test is

~~~ elixir
ptest [name1: type, name2: type, …], [option,…] do
  # code including assertions
  # this code can reference the values in name1 and name2
end
~~~

As the `options` are generally omitted, this simplifies to

~~~ elixir
ptest name1: type, name2: type, …  do
  # code including assertions
end
~~~

### Options

`repeat_for:` _n_

> Number of times to run the block, using different values each time.
  Defaults to 100.

`trace: true`

> Dumps the values used in each iteration of the block.

For example:

~~~ elixir
ptest [ a: int, b: int ], trace: true, repeat_for: 50 do
  assert a + b == b + a
end
~~~

## Type Specifications

A type specification is the name of a Quixir type generator,
optionally followed by a keyword list of constraints.

* `int`
* `int(min: 20, max: 50)`
* `int(must_have: [ 0, 10, 100 ])`

There's a full list of these generators, their constraints, and their
defaults, [below](#list-of-type-generators).

Sometimes type specifications can be nested. For example, this
specifies (possibly empty) lists of positive integers.

* `list(of: int(min: 1))`

And this is a generator for keyword lists:


* `list(of: tuple(like: { atom, string })`

### Back references to values

Occasionally you want to make the constraints of one type depend on
the value generated for a prior type. You do this using the pin
operator, `^`. For example, the following generates sets of two
integers where the second is guaranteed to be greater the first:

~~~ elixir
ptest a: int, b: int(min: ^a + 1) do
  assert a < b
end
~~~

## List of Type Generators

Quixir uses the [Pollution](https://github.com/pragdave/pollution)
library to create the streams of values that are injected into the
tests. These generators are documented [in HexDocs](https://hexdocs.pm/pollution/Pollution.VG.html). Here's a copy:

<!-- pollution -->

* any()
  Generates a stream of values of any of the types: atom, float, int,
  list, map, string, and tuple. Structs are not included, as they require
  additional information to create.
  
  If you need finer control over the types and values returned, see
  the `choose/2` function.
  

* atom(options \\ [])

* bool()
  Return a stream of random booleans (`true` or `false`).
  
  ## Example
        iex> import Pollution.{Generator, VG}
        iex> bool |> as_stream |> Enum.take(5)
        [true, false, true, true, false]
  

* choose(options)
  Each time a value is needed, randomly choose a generator
  from the list and invoke it.
  
  ## Example
        iex> import Pollution.{Generator, VG}
        iex> choose(from: [ int(min: 3, max: 7), bool ]) |> as_stream |> Enum.take(5)
        [6, false, 4, true, true]
  

* float(options \\ [])
  Return a stream of random floating point numbers.
  
  ## Example
  
        iex> import Pollution.{Generator, VG}
        iex> float |> as_stream |> Enum.take(5)
        [0.0, -1.0, 1.0, 5.0e-324, -5.0e-324]
  
  ## Options
  
  * `min:` _value_
  
    The minimum value that will be generated (default: -1e6).
  
  * `max:` _value_
  
    The maximum value that will be generated (default: 1e6).
  
  * `must_have:` [ _value,_ … ]
  
    Values that _must be_ included in the results. The default is
  
    [ 0.0, -1.0, 1.0, _epsilon_, _-epsilon_ ]
  
    (where _epsilon_ is the smallest expressible float)
  
    Must have values are automatically adjusted to account for the
    `min` and `max` values. For example, if you specify `min: 0.5` then
    only the 1.0 must-have value will be generated.
  
  ## See also
  
  • `positive_float()`   • `negative_float`   • `non_negative_float`
  

* int(options \\ [])
  Return a stream of random integers.
  
  ## Example
  
        iex> import Pollution.{Generator, VG}
        iex> int |> as_stream |> Enum.take(5)
        [0, -1, 1, 215, -401]
  
  ## Options
  
  * `min:` _value_
  
    The minimum value that will be generated (default: -1000).
  
  * `max:` _value_
  
    The maximum value that will be generated (default: 1000).
  
  * `must_have:` [ _value,_ … ]
  
    Values that _must be_ included in the results. The default is
  
    [ 0, -1, 1 ]
  
    Must have values are automatically adjusted to account for the
    `min` and `max` values. For example, if you specify `min: 0` then
    only the 0 and 1 must-have values will be generated.
  
  ## See also
  
  • `positive_int()`   • `negative_int`   • `non_negative_int`
  

* list()
  Return a stream of lists. Each list will have a random length (within limits),
  and each element in each list will be randomly chosen from the specified types.
  
  ## Example
  
      iex> import Pollution.{Generator, VG}
      iex> list(of: bool, max: 7) |> as_stream|> Enum.take(5)
      [
       [],
       [false, false, false],
       [false, true, true, false, true],
       [false, true, true, true, true, false, true],
       [true, true, false, false, false]
      ]
  
  There are a few special-case constructors:
  
  * `list(length)`
  
    Return lists of the given length
  
  * `list(generator)`
  
    Return lists whose elements are created by _generator_
  
        iex> list(bool) |> as_stream|> Enum.take(5)
  
  Otherwise, pass options:
  
  * `min:` _length_
  
    Minimum length of the lists returned. Default 0
  
  * `max:` _length_
  
    Maximum length of the lists returned. Default 100
  
  * `must_have:` [ _value_, … ]
  
    Values that must be returned. Defaults to returning an empty list
    (so the parameter is `must_have: [ [] ]` if the minimum length is
    zero, nothing otherwise.
  
  
  * `of:` _generator_
  
    Specifies the generator used to populate the lists.
  
    ## Examples
  
        iex> import Pollution.{Generator, VG}
  
        iex> list(of: int, min: 1, max: 5) |> as_stream |> Enum.take(4)
        [[0, -1, 1, -546], [442], [150], [-836, 540, -979]]
  
        iex> list(of: int, min: 1, max: 5) |> as_stream |> Enum.take(4)
        [[0], [-1, 1, 984, -206], [-246], [433, 125, -757]]
  
        iex> list(of: choose(from: [value(1), value(2)]), min: 1, max: 5)
        ...>         |> as_stream |> Enum.take(4)
        [[2], [1, 1, 2], [2, 2, 1, 1, 1], [2, 2, 1]]
  
        iex> list(of: seq(of: [value(1), value(2)]), min: 1, max: 5)
        ...>         |> as_stream |> Enum.take(4)
        [[1, 2], [1, 2, 1, 2], [1], [2, 1]]
  
  

* list(size)

* list(min, max)

* map(options \\ [])
  Create maps that either mirror a particular structure or that
  contain random numbers of elements.
  
  To create a stream of maps with a given structure, use the `like:`
  option:
  
      map(like: %{ name: string, age: int(min:0, max: 130) })
  
  In this example, the keys are static atoms—each generated map will
  have these two keys. You can also use generators as keys:
  
      map(like: %{ atom: string })
  
  This will generate single element maps, where each element has a
  random atom as a key and a random string as a value.
  
  To create a stream of variable size maps, use `of:`, optionally with
  the `min:` and `max:` options.
  
      map(of: { atom, string }, min: 3, max: 6)
  
  This will generate a stream of maps of between 3 and 6 elements
  each, when each element has an atom as a key and a string as a
  value.
  
  You can use generators such as `choose` and `pick_one` to make
  things more interesting:
  
      map(of: { atom, choose(from: [string, integer]) }, min: 3, max: 6)
  
  With this example, some elements will have a string value, and some
  will have an integer value.
  
  

* negative_float()
  Return a stream of floats not greater than -1.0. (Arguably this should
  be "not greater than _-epsilon_"). Same as `float(max: -1.0)`
  

* negative_int()
  Return a stream of integers less than 0. Same as `int(max: -1)`
  

* nonnegative_float()
  Return a stream of floats greater than or equal to zero.
  Same as `float(min: 0.0)`
  

* nonnegative_int()
  Return a stream of integers greater than or equal to 0.
  Same as `int(min: 0)`
  

* pick_one(options)
  Randomly chooses a generator from the list, and then returns a stream of
  values that it produces. This choice is made only once—call `pick_one`
  again to get a different result.
  
  ## Examples
  
      iex> import Pollution.{Generator, VG}
      iex> stream = pick_one(from: [int, bool]) |> as_stream
      iex> Enum.take(stream, 5)
      [0, -1, 1, -223, 72]
      iex> Enum.take(stream, 5)
      [0, -1, 1, -553, 847]
      iex> Enum.take(stream, 5)
      [0, -1, 1, -518, -692]
      iex> Enum.take(stream, 5)
      [0, -1, 1, 580, 668]
      iex> Enum.take(stream, 5)
      [0, -1, 1, -989, -353]
      iex> stream = pick_one(from: [int, bool]) |> as_stream
      iex> Enum.take(stream, 5)
      [true, false, false, false, false]
      iex> Enum.take(stream, 5)
      [false, true, false, false, false]
  

* positive_float()
  Return a stream of floats not less than 1.0. (Arguably this should
  be "not less than _epsilon_"). Same as `float(min: 1.0)`
  

* positive_int()
  Return a stream of integers not less than 1. Same as `int(min: 1)`
  

* seq(options)
  Give `seq` a list of generators (using the `of:` option).
  It will cycle through these as it streams values.
  
  ## Examples
  
      iex> import Pollution.{Generator, VG}
      iex> seq(of: [int, bool, float]) |> as_stream |> Enum.take(10)
      [0, true, 0.0, -1, true, -1.0, 1, true, 1.0, -702]
  

* string(options \\ [])
  Return a stream of strings of randomly varying length.
  
  ## Examples
  
      iex> import Pollution.{Generator, VG}
      iex> string(max: 4) |> as_stream |> Enum.take(5)
      ["", " ", "墍勧", "㘃牸ྥ姷", ""]
      iex> string(chars: :digits, max: 4) |> as_stream |> Enum.take(5)
      ["33", "", "7", "6223", "55"]
  
  ## Options
  
  * `min:` _length_
  
     The minimum length of the returned string (default 0)
  
  * `max:` _length_
  
     The maximum length of the returned string (default 300)
  
  * `chars: :ascii | :digits | :lower | :printable | :upper | :utf`
  
     The set of characters that may be included in the result:
  
     | :ascii     |  0..127     |
     | :digits    |  ?0..?9     |
     | :lower     |  ?a..?z     |
     | :printable |  32..126    |
     | :upper     |  ?A..?Z     |
     | :utf       |  0..0xd7af  |
  
     The default is `:utf8`.
  
  * `must_have:` _list_
  
    A list of strings that must be in the result stream. Defaults to `["", "␠"]`,
    filtered by the maximum and minimum lengths.
  
  
  

* struct(template)
  Generate a stream of structs. Before starting, the generator reflects
  on the struct that is passed in, looking at the types of the values
  of each field. It then maps this onto a `map()` generator, using
  appropriate subgenerators for each of those fields.
  
  For example, given:
  
       iex> defmodule MyStruct
       iex>    defstruct an_atom: :a, an_int: 0, other: nil
       iex> end
  
  You could call
  
      iex> struct(MyStruct)
  
  As well as passing in the name of a struct, you can pass in
  an instance:
  
      iex> struct(%MyStruct{})
  
  In either case, the result would be a stream of MyStructs, as if you
  had called
  
      map(like: %{ an_atom: atom,
                   an_int:  int,
                   other:   any,
                   __struct__: MyStruct)
  
  If you supply generators to the struct you pass in, these will be
  used in place of generators for the defaults:
  
      struct(%MyStruct{an_int: int(min: 20), other: string})
  

* tuple(options \\ [])
  Generate a stream of tuples. The default is to create tuples of varying sizes
  with varying content, which is unlikely to be useful. You'll more likely want
  to use the `like:` option, which sets a template for the tuples.
  
  ## Example
  
      iex> import Pollution.{Generator, VG}
      iex> tuple(like: { value("insert"), string(chars: :upper, max: 10)}) |>
      ...> as_stream |> Enum.take(3)
      [{"insert", "M"}, {"insert", "GFOHZNDER"}, {"insert", "FCDO"}]
  
  ## Options
  
  * `min:` _size_  • `max:` _size_
  
    Set the minimum and maximum sizes of the returned tuples. The defaults are
    0 and 6, but this is overridden by the actual size
    if the `like:` option is specified.
  
  * `like:` { _template_ }
  
    A template of generators used to fill the tuple. The generated tuples will
    have the same size as the template, and each element wil be generated from
    the corresponding generator in the template. For example, a `Keyword`
    list could be generated using
  
        iex> list(of: tuple(like: { atom, string(chars: lower, max: 10) })) |> as_stream |> Enum.take(5)
  
  

* value(val)
  Generates an infinite stream where each element is its parameter.
  
  ## Example
  
      iex> import Pollution.{Generator, VG}
      iex> value("nom") |> as_stream |> Enum.take(3)
      ["nom", "nom", "nom"]
  
  


## Shrinking

Coming soon…


## Copyright and License

Copyright © 2016 Dave Thomas <dave@pragdave.me>

Licensed under the Apache License, Version 2.0 (the “License”);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

> http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an _AS IS_ BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

