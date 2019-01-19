*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_cancelled_Snmp
    [Documentation]    Testcase to verify the if the events are generated when reload in cancelled.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-301    @globalid=2226222    @priority=P1    @user_interface=Snmp
    Command    n1_session1    clear active event
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    #schdule the reload for the device from the CLI.
    Command    n1_session1    reload in 100    timeout_exception=0
    command    n1_session1    y    timeout_exception=0    prompt=#
    ${events}=    command    n1_session1    show event
    #Cancel the reload
    command    n1_session1    stop reload
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    A scheduled reload has been cancelled
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_cancelled_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_cancelled_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    ${DUT}
    command    ${DUT}    stop reload
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
