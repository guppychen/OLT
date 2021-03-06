*** Settings ***
Documentation     Test suite verifies PM session bins will support a common set of attributes and attributes specific to the Monitored Entity - not synced to TOD
Resource          base.robot
Force Tags        @feature=PM    @author=llim

*** Variables ***
${historical_bin}          12 
${bin_time}                5 
${bin_duration}            five-minutes

*** Test Case ***

TC1: PM session bins will support a common set of attributes and attributes specific to the Monitored Entity 

     [Documentation]    Test case verifies PM sessions bins support a required attributes 
     ...                1.  Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful
     ...                2.  Create 10 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful
     ...                3.  Enable Ethernet PM session at time which is not synced to TOD in Eternet interface and verify it is successful
     ...                4.  Verify common attributes and attributes specific to its monitored entity are present in current bin 
     ...                5.  Verify common attributes and attributes specific to its monitored entity are present in historical bins 
     ...                6.  Verify packet counters of each attributes have 3000 K in the bins

     [Tags]    @globalid=2201635    @tcid=AXOS_E72_PARENT-TC-26    @priority=P3    @functional   @eut=NGPON2-4    @user_interface=CLI
     [Teardown]   PM Teardown

     Log  ******************** Configure a Grade of Service profile (GoS) with specific attributes and verify its is successful ******************** 
     Configure Grade Of Service Profile    n1    ${profile_name}    ${threshold}
     Verify Grade Of Service Profile Configured    n1   ${profile_name}

     Log  ******************** Create 10 K Frames of traffic stream for each matching attributes and traffic flow in interface is successful ******************** 
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1
     Clear Ethernet Interface Counter    n1    ${DEVICES.n1.ports.p1.port}
     Tg Create Untagged Stream On Port    tg1    framesize    p2    p1    mac_src=${src_mac}    mac_dst=${dst_mac}    l3_protocol=ipv4
     ...                                  ip_src_addr=${stc_ethernet_ip}    ip_dst_addr=${stc_pon_ip}    rate_pps=10000    frame_size=512   length_mode=fixed
     Tg Start All Traffic    tg1
     Verify Ethernet Interface Traffic    n1    ${DEVICES.n1.ports.p1.port}

     tg save config into file  tg1  /tmp/pm.xml

     Log  ******************** Enable Ethernet PM session of 5 minutes Measurement interval (MI) and 12 historical bins in the Eternet interface and verify its successful *******
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Not Sync TOD    n1
     Enable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Verify Ethernet PM Session Is Created    n1    ${DEVICES.n1.ports.p1.port}    ${session_number}

     Log  ****** Verify common attributes and attributes specific to its monitored entity are present in current bin and historical bins ***********
     Verify Not Synced TOD Common Bin Attribites    n1    ${DEVICES.n1.ports.p1.port}
     Verify Monitored entity    n1    ${DEVICES.n1.ports.p1.port}

     Log  ********** Verify packet counetrs matches 3000 K for each attributes in the bins ***********
     Verify Ethernet PM Session Counters Five Minutes    n1    ${DEVICES.n1.ports.p1.port}


*** Keywords ***
PM Teardown
    [Documentation]    teardown
     Log  ******************** Unconfigure PM session from interface and Grade Of Service profile ********************
     Disable Ethernet PM Session In Interface    n1    ${DEVICES.n1.ports.p1.port}
     Unconfigure Grade Of Service Profile    n1

     Log  ***************** stop the traffic********************
     Tg Stop All Traffic     tg1
     TG Disable All Traffic     tg1