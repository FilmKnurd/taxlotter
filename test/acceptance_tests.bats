
setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../:$PATH"
}

@test "Exit 1 if no algorithm supplied" {
  refute taxlotter
}

@test "Exit 1 if input is invalid" {
  run bash -c "echo -e '2021-01-01,foo,10000,1\n' | taxlotter -a fifo"
  assert_failure
}

@test "Basic fifo processing" {
  run bash -c "echo -e '2021-01-01,buy,10000.00,1.00000000\n2021-01-02,buy,20000.00,1.00000000\n2021-02-01,sell,20000.00,1.50000000' | taxlotter -a fifo"
  assert_output '2,2021-01-02,20000.00,0.50000000'
}

@test "Basic hifo processing" {
  run bash -c "echo -e '2021-01-01,buy,10000.00,1.00000000\n2021-01-02,buy,20000.00,1.00000000\n2021-02-01,sell,20000.00,1.50000000' | taxlotter -a hifo"
  assert_output '1,2021-01-01,10000.00,0.50000000'
}
