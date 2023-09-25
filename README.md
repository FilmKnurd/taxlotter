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
