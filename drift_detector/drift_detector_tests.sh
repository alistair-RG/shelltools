#!/bin/bash
####### This is our single line of magic that we want to test in dfferent scenarios

command()
{
    echo "Parsing:" $1
    # --exit-status - return code is based on result of query
    # .individualResults[-1] - pick the last object in the array of results (this will be the most recent)
    # | not - Flyway returns 'true' if drift detected, we need to invert this to be able to get a non-zero return code from the --exit-status flag
    # Limitations - it will fail if you give it an empty JSON file/array
    # How does it work ?
    # [.individualResults[] - break the array of reports up
    # select(.operation=="drift") - pick the ones that are drift reports
    # .driftDetected - pick out just the field we are interested in
    # There are brackets [ ] around the preceeding section to get jq to produce a formatted array of results for the next step
    # .[-1] - take the last record in the array
    jq --exit-status '[.individualResults[] | select(.operation=="drift") | .driftDetected ] | .[-1] | not' $1
    global_result=$?
}
###### Tests
echo "1: Testing for no drift correctly identified and flagged"
command "nodrift_example.json"
if [ $global_result -ne 0 ]; then
    echo "*** TEST FAIL: No drift should be presented but return value suggests it is"
    exit 1
fi
##############
echo "2: Testing for drift correctly identified and flagged in a file with just one drift report"
command "drift_example_1.json"
if [ $global_result -ne 1 ]; then
    echo "*** TEST FAIL: drift should be presented but return value suggests it is not"
    exit 1
fi
##############
echo "3: Testing for drift correctly identified and flagged (based on last report) in a file with several drift reports"
command "drift_example_2.json"
if [ $global_result -ne 1 ]; then
    echo "*** TEST FAIL: drift should be presented but return value suggests it is not"
    exit 1
fi
##############
# echo "4: Testing it doesn't do anything stupid with an empty JSON file"
# command "empty.json"
# if [ $global_result -ne 0 ]; then
#     echo "*** TEST FAIL: nothing in the file so no drift should be flagged"
#     exit 1
# fi
##############
echo "5: Multiple checks in a single json, make sure it finds the last drift report"
command "drift_and_change.json"
if [ $global_result -ne 1 ]; then
    echo "*** TEST FAIL: drift should be presented but return value suggests it is not"
    exit 1
fi

echo "*** All tests pass ! ***"
exit 0
