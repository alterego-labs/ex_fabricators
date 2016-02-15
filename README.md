# ExFabricators

This small library is fully inspired by Fabrication gem for Rails and has the same goals: single
point to generate structs and structs trees for tests.

This library gives you a some small DSL for defining fabricators.

It is a dirty implementation which has a many restrictions but is good enough for starting.

## Installation

Right now this library does not exists in the Hex package manager, but you can install it
from github:

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
