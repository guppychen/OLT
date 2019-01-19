*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
aaa_accounting_tacacs_send_to_none
    [Documentation]    aaa_accounting_tacacs_send_to_none
    [Tags]    @author= Sean Wang    @globalid=2533169    @tcid=AXOS_E72_PARENT-TC-4454
    [Setup]    case setup
    log    show aaa
    Configure    eutA    aaa accounting tacacs send-to none
    check tacacs accounting send    none
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    do show aaa

case teardown
    log    Enter case teardown
    Configure    eutA    aaa accounting tacacs send-to none

check tacacs accounting send
    [Arguments]    ${tacacs_send}
    ${result}    cli    eutA    show run aaa accounting
    ${tacacs}    ${group1}    should Match Regexp    ${result}    aaa accounting tacacs send-to (\\w+)
    should contain    ${group1}    ${tacacs_send}
    [Return]   ${group1}