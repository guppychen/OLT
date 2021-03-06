*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_high-loss-tca_Snmp
    [Documentation]    Testcase to verify that alarm is generated when the Loss ratio threshold exceeds.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-331   @user=root   @user=root   @user=root    @globalid=2226252    @priority=P1    @user_interface=Snmp
    Cli    n1_session2    cli
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost high-loss-tca MAJOR
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    high-loss-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_high-loss-tca_Snmp    n1_session2

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_high-loss-tca_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    dcli evtmgrd evtpost high-loss-tca CLEAR
    command    ${DUT}    cli
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    #Remove the SNMP v2
    SNMP_v2_teardown    ${DUT}
    Disconnect    ${DUT}
