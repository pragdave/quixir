# Quixir: Pure Elixir Property-based Testing

[Property-based
testing](http://blog.jessitron.com/2013/04/property-based-testing-what-is-it.html)
is a technique for testing your code by considering the types of its
inputs and outputs. Rather that using explicit values in your tests,
you instead try to define the types of the values to feed it, and the
properties of the results produced.

For example, given a list, you know that reversing it should produce a
list with the same number of elements. You can specify this in Quixir
like this:

~~~ elixir
props some_list: list do
  reversed = my_reverse(some_list)
  assert length(reversed) == length(some_list)
end
~~~

This says that, for any list `some_list`, passing it through
`my_reverse` will produce a result of the same length.

But what list do we actually pass in? The simple answer is "lots of
them." In this particular case, we'll generate a hundred lists. These
will vary in length, and vary in content, but we guarantee to include
t least one empty list and one list containing one element (as these
are both common boundary cases that can break code). The overall test
passes if the assertion is contains is try for all these lists.

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

'nuf hype. Here are the details. But first…


### Alternatives

For a different approach, see
[ExCheck](https://github.com/parroty/excheck), built on
[triq](https://github.com/krestenkrab/triq).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `pbt` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:pbt, "~> 0.1.0"}]
    end
    ```

  2. Ensure `pbt` is started before your application:

    ```elixir
    def application do
      [applications: [:pbt]]
    end
    ```

