#!/bin/bash
####### This is our single line of magic that we want to test in dfferent scenarios
command()
{
    echo "Parsing:" $1
    # --exit-status - return code is based on result of query
    # .individualResults[-1] - pick the last object in the array of results (this will be the most recent)
    # | not - Flyway returns 'true' if drift detected, we need to invert this to be able to get a non-zero return code from the --exit-status flag
    # Limitations: If you have a report with multiple report types in it (check, code ..) then it will look for the last object in the array regardless
    jq --exit-status '.individualResults[-1].driftDetected | not' $1
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
echo "3: Testing for drift correctly identified and flagged (based on earliest report) in a file with several drift reports"
command "drift_example_2.json"
if [ $global_result -ne 1 ]; then
    echo "*** TEST FAIL: drift should be presented but return value suggests it is not"
    exit 1
fi
##############
echo "4: Testing it doesn't do anything stupid with an empty JSON file"
command "empty.json"
if [ $global_result -ne 0 ]; then
    echo "*** TEST FAIL: nothing in the file so no drift should be flagged"
    exit 1
fi

echo "*** All tests pass ! ***"
exit 0
