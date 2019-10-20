# !/bin/bash
# testSuite_qos.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.


TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_qos_suite" # Name of this test suite; will be used to
                                           # identify this suite in XML file. This
                                           # should be a single string, no spaces
                                           # please.

L_BUILDTYPE=$1 # Build type, passed in from bamboo.sh as a convenience
               # value. If you run this script from the command line,
               # you will need to supply this value in the same way
               # that bamboo.sh defines it if you wish to use it.

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================
#-------------------------------------------------------------------------------
# Test:
#     test_qosCases
#-------------------------------------------------------------------------------
export LOADFILE="qos.load"
export PYTHONPATH="../test"
pushd  {SST_REFERENCE_ELEMENTS}/ember/tests

qos_Template() {
qos_case=$1

    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_qos_${qos_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    tmpFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.tmp"
    referenceFile="${SST_REFERENCE_ELEMENTS}/ember/tests/refFiles/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})

    LOADFILE="qos.load"
    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"
    sutArgs="${SST_ROOT}/sst-elements/src/sst/elements/ember/tests/test_qos_${qos_case}.sh"

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} ${sutArgs} > $outFile
        RetVal=$? 
        TIME_FLAG=$SSTTESTTEMPFILES/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 
        if [ $RetVal != 0 ]  
        then
             echo ' '; echo WARNING: sst did not finish normally ; echo ' '
             ls -l ${sut}
             fail " WARNING: sst did not finish normally, RetVal=$RetVal"
             wc $referenceFile $outFile
             return
        fi
        myWC $outFile $referenceFile

        diff ${referenceFile} ${outFile}
        if [ $? -ne 0 ]
        then
            echo ' '; echo MATCH FAILED; echo ' '
            fail " MATCH FAILED"
        fi        
    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi
    tail -1 $outFile

}

test_qos_dragonfly() {
qos_Template dragonfly
}

test_qos_fattree() {
qos_Template fattree
}

test_qos_hyperx() {
qos_Template hyperx 
}


export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS


# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)
