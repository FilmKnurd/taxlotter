# Taxlotter

Command line utilty to calculate tax lots given lines of comma delimited trade events.

## Setup

Built with:
- Erlang 26.0.2
- Elixir 1.15.4

### TL;DR
Just run `make` to do all the things

```shell
$ make
```

- Fetches Bats submodules (for acceptance tests)
- Fetches dependencies
- Runs unit tests
- Compiles executable script
- Runs acceptance tests

### Building
To build the script, there are some dependencies to fetch.
1. To clone the Bats testing utility submodules, run:
    ```shell
    $ git submodules init
    $ git submodules update
    ```
2. Fetch elixir dependencies:
    ```shell
    $ mix deps.get
    ```
3. Compile the final executable:
    ```shell
    $ mix escript.build
    ```
If all goes well, an executable script, `taxlotter`, is compiled into the root of the project.

### Testing
**Unit Tests**
```shell
$ mix test
```

**Acceptance Tests**
```shell
$ test/bats/bin/bats test/acceptance_tests.bats
```

## Usage
Pipe lines of trade data into `taxlotter` and specify the tax lot algorithm to use. It will output tax lots.
```shell
$ echo -e '2021-01-01,buy,10000.00,1.00000000\n2021-01-02,buy,20000.00,1.00000000\n2021-02-01,sell,20000.00,1.50000000' | taxlotter -a fifo
2,2021-01-02,20000.00,0.50000000

$ echo -e '2021-01-01,buy,10000.00,1.00000000\n2021-01-02,buy,20000.00,1.00000000\n2021-02-01,sell,20000.00,1.50000000' | taxlotter -a hifo
1,2021-01-01,10000.00,0.50000000
```

## Theory of Operation

A little about the code structure.

### TaxLotter.CLI
This module is the main entry point of the program. It handles parsing arguments, streaming input into `TaxLotter.compute/2`, and printing errors and final output.

### TaxLotter.compute/2
This function lays out the map/reduce flow to compute tax lots.
1. Add an index to lines (useful for error reporting)
2. Validate each line (creates Trade structs)
3. Pass the list of Trade structs to the process lots reducer
4. Return the list of computed lots

### TaxLotter.Operators
This is the meat of the program.

**validate_trade/1**

This functions validates the input received by creating a Trade Ecto schema and running changeset validators. If validation fails, it raises an InvalidTrade error with line number and changeset validation messages.

**process_lots/2**

Two implementations are provided that match on the trade type.

In the case of a buy, this function either adds a new lot to the accumulator or updates an existing lot if a lot already exists with the same date as the trade being processed. The update operation adds the quantity from the trade to the lot and calculates a new averaged price.

In the case of a sell, this function sorts the accumulated lots based on the chosen algorithm and then recursively removes quantity from the lots until all the trade's quantity is consumed. It updates the accumulator with whatever lots are remaining.
