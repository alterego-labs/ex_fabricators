# ExFabricators

This small library is fully inspired by Fabrication gem for Rails and has the same goals: single
point to generate structs and structs trees for tests.

This library gives you a some small DSL for defining fabricators.

It is a dirty implementation which has a many restrictions but is good enough for starting.

## Installation

You can install this package from Hex:

```elixir
  def deps do
    [{:ex_fabricators, "~> 0.0.2"}]
  end
```

Or you can install it from github:

```elixir
  def deps do
    [{:ex_fabricators, github: "alterego-labs/ex_fabricators"}]
  end
```

## Usage

For first you need to define a context in which you will define fabricators. For example, it
may be `test/fabricators.ex`:

```elixir
  defmodule Fabricators do
    use ExFabricators.Builder

    fabricator :team, YourApp.Structs.Team, %{}
  end
```

Then in tests or in setup callbacks you can run fabricators like this:

```elixir
  Fabricators.build :team
```

As a result you give initialized `YourApp.Structs.Team` struct with default properties.

If you try to build undefined fabricator `RuntimeError` will be thrown.

The last parameter of the `fabricator/3` macro is a Map with options. So, for example,
if your Team struct has `id`
property and you want to set it while building do it like the following:
  
```elixir
  fabricator :team, YourApp.Structs.Team, %{id: 2}
```

The you can provide some dependencies for the building structs:
  
```elixir
  fabricator :event, YourApp.Structs.Event, %{home_team: Fabricators.build(:team)}
```

## Multifile support

During the time the single point for defining fabricators becomes the mess of unmantainable code.
So for first I think we must to have ability to define fabricators in different files and
load them in `test_helper`.

Let's consider an example:

```elixir test/fabriactors/team_fabricator.ex
use ExFabricators.Builder

fabricator :team, YourApp.Structs.Team, %{}
```

```elixir test/fabriactors/event_fabricator.ex
use ExFabricators.Builder

fabricator :event, YourApp.Structs.Event %{}
```

```elixir test/test_helper.exs
ExFabricators.take_all!()
```

API for calling fabricators in tests will be changed a little:

```elixir
defmodule ... do
  test "..." do
    team = ExFabricators.build :team
  end
end
```

This is the most wanted feature and will be included to release _v0.1.0_.
