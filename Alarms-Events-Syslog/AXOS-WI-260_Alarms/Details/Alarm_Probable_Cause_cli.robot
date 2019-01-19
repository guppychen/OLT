*** Settings ***
Documentation     This test suite is going to verify whether the alarm probable-cause is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms     n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Suite Teardown     Clearing_Alarms       n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar    @reload

*** Test Cases ***

Alarm_Probable_Cause
    [Documentation]    Test case verifies alarm probable-cause is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition
    ...                2.Verify the field is correct in the active alarm. show alarm active
    ...                3.Verify the field is correct in the alarm history. show alarm history
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved
    ...                6.Verify the field is correct in the archive alarm. show alarm archive
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2833    @functional    @priority=P2      @user_interface=CLI      @runtime=long

    Log    *** Verifying Alarm probable cause is displayed correctly in Active alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      active_alarm_loss_of_signal    signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      alarm=ntp_prov_act     type=active
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      active_alarm_rmon_session      rmon_session

    Log    *** Verifying Alarm probable cause is displayed correctly in Alarm definitions ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      definition_alarm_loss_of_signal   signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      alarm=ntp_prov_act     type=definition
    Run Keyword And Continue On Failure        Checking_Alarm_definition_parameters      n1      probable-cause
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      definition_alarm_rmon_session     rmon_session

    Log    *** Verifying Alarm probable cause is displayed correctly in Alarm history ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      history_alarm_loss_of_signal    signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      alarm=ntp_prov_his     type=history
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      history_alarm_rmon_session     rmon_session


    Log    *** Verifying Alarm probable cause is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure      Suppressing Active alarms    n1
    #Run Keyword And Continue On Failure    Verify Suppressing Alarms        n1       probable_cause      suppressed_alarm_loss_of_signal
    #Run Keyword And Continue On Failure     Verify Suppressing Alarms        n1       probable_cause      suppressed_alarm_rmon_session
    #Run Keyword And Continue On Failure       Unsuppressing Active alarms    n1

    Log    *** Verifying Alarm probable cause is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms    n1       probable_cause      shelved_ntp_prov

    Log    *** Verifying Alarm probable cause is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged     n1       probable_cause     shelved_ntp_prov 

    Log    *** Verifying Alarm probable cause is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm      n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload System     n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      archiving_alarm_loss_of_signal    signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      alarm=ntp_prov_his     type=archive
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       probable_cause      archiving_alarm_rmon_session    rmon_session

