*** Settings ***
Documentation     Test suite to verify ICMP Ping pattern option
Resource          base.robot
Force Tags        @feature=AXOS-WI-1120 ICMP    @author=llim

*** Variables ***

*** Test Case ***

Ping And Verify Ipv4 Localhost Using Pattern Option Via Serial 
     [Documentation]    Test case verifies ICMP Ping using Pattern option can be executed successfully
     ...                1. Ping IPV4 localhost 5 times using -p option via serial
     ...                2. Verify that all 5 pings were successful

     [Tags]    @globalid=2197112    @tcid=AXOS_E72_PARENT-TC-941    @priority=P3    @functional   @eut=E7-2-NGPON2-4    @user_interface=CLI

    cli    n1_console    ping -p ${hex_pattern} ${ipv4_localhost} -c ${ping_count}
    Result Should Contain      ${ping_count} packets transmitted
    Result Should Contain      ${ping_count} received    

*** Keywords ***
