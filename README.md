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
tests. These generators are documented [in HexDocs](https://hexdocs.pm/pollution/Pollution.VG.html), and embedded here for convenience.

<iframe src="https://hexdocs.pm/pollution/Pollution.VG.html" height="80%" width="100%"></iframe>

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

