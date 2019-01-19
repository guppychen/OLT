*** Settings ***
Documentation     Test suite verifies the users with appropriate permission to enable/disable PM session bins and the same should be reported and recorded in syslog
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Variables ***
${historical_bin}          12 
${bin_time}                5 
${bin_duration}            five-minutes

*** Test Case ***

TC1: Verify user with appropriate permissions must be able to enable/disable the PM Session Current and Historcal Bins

     [Documentation]    Test case verifies user with appropriate permissions to enable/disable the bins
     ...                1. Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful
     ...                2. Configure the user with valid role to enable/disable the bins
     ...                3. Create 10 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful
     ...                4. Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful
     ...                5. Verify packet counters of each attributes have 3000 K in the bins
     ...                6. Disable Ethernet PM session bin and verify the following bin got disabled,same is reported in management plane and packet counter stops incrementing
     ...                7. Enable Ethernet PM session again and verify the following bin should be enabled,same is reported in management plane and packet counter starts 

     [Tags]    @globalid=2201639    @tcid=AXOS_E72_PARENT-TC-30    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI
     [Teardown]   PM Teardown

     Log  ******************** Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful ******************** 
     Configure Grade Of Service Profile    n1    ${profile_name}    ${threshold}
     Verify Grade Of Service Profile Configured    n1   ${profile_name}
     Configure Users    n1

     Log  ******************** Create 10 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful ********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1
     Clear Ethernet Interface Counter    n1    ${DEVICES.n1.ports.p1.port}
     Tg Create Untagged Stream On Port    tg1    framesize    p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=512   length_mode=fixed
     Tg Start All Traffic    tg1
     Verify Ethernet Interface Traffic    n1    ${DEVICES.n1.ports.p1.port}

     Log  ******************** Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Check Time Of Day    n1
     Enable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Verify Ethernet PM Session Is Created    n1    ${DEVICES.n1.ports.p1.port}    ${session_number}

     Log  ****** Disable bin and verify it got disabled and reported to management plane. Verify counters stops counting and starts again for new session ********
     Bin Wait Time    ${bin_time}
     Verify Second Performance Monitoring Bin    n1    ${DEVICES.n1.ports.p1.port}
     Bin Wait Time    ${bin_time}
     Verify Ethernet PM Session Counters Five Minutes    n1    ${DEVICES.n1.ports.p1.port}

*** Keywords ***
PM Teardown
    [Documentation]    teardown
    Disable Bin Authorized User    n1_auth    ${DEVICES.n1.ports.p1.port}

     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Unconfigure Grade Of Service Profile    n1

     Log  ***************** stop the traffic********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1