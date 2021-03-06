*** Settings ***
Resource          ./base.robot

*** Variables ***
${ntp1}    1
${ntp2}    2

*** Test Cases ***
tc_check NTP1 status after reload
    [Documentation]    check NTP1 status after reload
    [Tags]    @author=Sean Wang    @globalid=2328802    @tcid=AXOS_E72_PARENT-TC-1845    @feature=Timing    @subfeature=NTP
    [Setup]    case setup
    Configure    eutA    ntp server ${ntp1} ${server_ip[2]}
    log    STEP:2 (Client/Server)Verify Show ntp associations/details
    check_ntp_status    eutA    ${ntp_staus[0]}
    Configure    eutA    timezone Asia/Chongqing
    Wait Until Keyword Succeeds    15 min    15 sec    check_ntp_server    eutA    ${server_ip[2]}    ${connection_status[0]}
    ...    ${synchronize_status[0]}    ${source_status[0]}
    ${system_time}    get current date
    ${device_time}    get_device_clock    eutA
    ${result1}    convert Date    ${system_time}    epoch
    ${result2}    convert Date    ${device_time}    epoch
    should be true    abs(${result2}- ${result1})<${timegap}
    Configure    eutA    ntp server ${ntp1} ${server_ip[2]}
    Configure    eutA    ntp server ${ntp2} ${server_ip[1]}
    check_ntp_status    eutA    ${ntp_staus[0]}
    Configure    eutA    timezone Asia/Chongqing
    
    reload system   eutA

    Wait Until Keyword Succeeds    5 min    15 sec    check_ntp_server    eutA    ${server_ip[2]}    ${connection_status[0]}
    ...    ${synchronize_status[0]}    ${source_status[0]}
    ${system_time}    get current date
    ${device_time}    get_device_clock    eutA
    ${result1}    convert Date    ${system_time}    epoch
    ${result2}    convert Date    ${device_time}    epoch
    should be true    abs(${result2}- ${result1})<${timegap}
    ${result}    cli    eutA    show run ntp
    should contain    ${result}    ntp server 1
    should contain    ${result}    ntp server 2
    ${result}    cli    eutA    show ntp
    should contain    ${result}    connection-status \ \ \Connected
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    Configure    eutA    timezone Africa/Algiers

case teardown
    log    Enter case teardown
    Configure    eutA    no ntp server ${ntp2}
    Configure    eutA    ntp server ${ntp1} ${server_ip[0]}
    cli    eutA    copy running-config startup-config
    
check ngpon lost
    # ${resutl}    Wait Until Device Restarted     ${DEVICES.eutB.ip}
    ${result}    cli    eutA    show info
    [Return]    ${result}
