set -e

cabal update

echo "*** Building the builder ***"
cabal build plfa:exe:builder

echo "*** Building plfa ***"
cabal run builder -- build

# timeout returns error code
set +e

echo "*** Running server ***"
output=$(timeout -- 10 make serve)

ec=$?

# restore errors
set -e

# Server should timeout i.e. return exit code 124
if [[ ec -ne 124 ]]; then
  echo "*** Server returned failure ***: $ec"
  exit 1
fi

if [[ $output =~ .*Serving[[:space:]]files[[:space:]]from:[[:space:]]./.* ]]; then
  echo "*** Server launched successfully. ***"
else
  echo -e "*** Did not receive expected output. Received: ***\n"
  echo -e "$output\n"
  exit 1
fi
