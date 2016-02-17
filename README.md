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

For first you must to define your fabricators. By default the folder for fabricators is
`test/fabricators` so just add under this folder files with content like the following:

```elixir
use ExFabricators.Builder

fabricator :team, YourApp.Structs.Team
```

Save code above into `test/fabricators/team_fabricator.exs` file. Always name files by 
`<context>_fabricator.exs` pattern because this package expects it.

The next step is to load fabricators. For this add the next line into `test_helper.exs`:

```elixir
ExFabricators.take_all!(Path.join(File.cwd!, "test/fabricators"))
```

Then in tests or in setup callbacks you can run fabricators like this:

```elixir
  Fabricators.build(:team)
```

As a result you give initialized `YourApp.Structs.Team` struct with default properties.

If you try to build undefined fabricator `RuntimeError` will be thrown.

The last parameter of the `fabricator/3` macro is an anonymous function that must return a Map.
So, for example, if your Team struct has `id` property and you want to set it while building do it
like the following:
  
```elixir
  fabricator :team, YourApp.Structs.Team, fn -> %{id: 2} end
```

The you can provide some dependencies for the building structs:
  
```elixir
  fabricator :event, YourApp.Structs.Event, fn -> %{home_team: Fabricators.build(:team)} end
```
