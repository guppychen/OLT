*** Settings ***
Documentation     This test suite is going to verify alarm history logs are cleared and recorded in syslog server
Resource          base.robot

Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support   @author=ssekar

*** Test Cases ***
Clear_alarm_history_log
    [Documentation]    Test case verifies alarm history logs are cleared.
    ...    1. Trigger some alarms and check alarms are stored in history.
    ...    2. Clear the alarm history and check alarm history logs are cleared.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2855    @functional    @priority=P2    @user_interface=CLI
    Log    *** Getting Alarm history total count ***
    ${total_count}    Getting Alarm history total count    n1
    Set Suite Variable    ${total_count}    ${total_count}

    Log    *** Triggering some alarms if alarm history total count is 0 ***
    Run Keyword If    ${total_count} == 0    Run Keywords    Triggering any one alarm for severity INFO    device=n1     user_interface=cli
    ...    AND     Trigerring NTP prov alarm      device=n1
    ...    AND    BuiltIn.Sleep    5s
    ...    AND    Clear running-config INFO alarm      device=n1     user_interface=cli

    Log    *** Checking Alarm history count gets increased if the value is 0 ***
    ${count}     Run Keyword If    ${total_count} == 0          Getting Alarm history total count    n1
    Run Keyword If    ${total_count} == 0          Should Be True      ${count}>0

    Log    *** verifying syslog server captured history log clearance ***
    Wait Until Keyword Succeeds      2 min     10 sec      check clearning alarm in syslog server


*** Keywords ***
check clearning alarm in syslog server
    [Documentation]  used for check alarm cleared in syslog
    Clearing alarm history logs    n1
    ${count}         Getting Alarm history total count    n1
    Should Be Equal As Integers    ${count}    0
    Clearing history log captured in syslog server     n1_local_pc      ${DEVICES.n1_local_pc.ip}      ${DEVICES.n1_local_pc.password}