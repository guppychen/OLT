*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_start_vca_join_ip_with_not_flow_ip_vlan_changed
    [Documentation]    check it can works fine    
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4567      @globalid=2533291      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI        
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    STEP 1: start vca join ip with not flow ip vlan, start traffic and check vca parameter display correctly
    log    set downstream traffic
    create_raw_traffic_udp    tg1    dpstream1    subscriber_p1    service_p1    ${service_vlan}    &{tg_ds_param1}
    log    start vca join ip with not flow ip vlan, start traffic,    
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan} duration ${dur_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    show vca and check rx-packets correctly   
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA
    Wait Until Keyword Succeeds    2min    5s    check_igmp_multicast_group_summary    eutA    ${vca_ip}    ${service_vlan}    ${igmp_param.interface}
    
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    cli    eutA    stop vca now
    service_point_remove_vlan    service_point_list1    ${service_vlan}

    
    log    STEP 2: start vca join ip with not flow ip vlan changed, start traffic and check vca parameter display correctly
    log    clear vca counter before send traffic
    service_point_add_vlan    service_point_list1    ${service_vlan2}
    cli    eutA    clear vca counters all  
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream2    subscriber_p1    service_p1    ${service_vlan2}    &{tg_ds_param1}
    log    start vca join ip with not flow ip, vlan changed 
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan2} duration ${dur_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    show vca and check its rx-packets correctly 
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA
    Wait Until Keyword Succeeds    2min    5s    check_igmp_multicast_group_summary    eutA    ${vca_ip}    ${service_vlan2}    ${igmp_param.interface}
    
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    cli    eutA    stop vca now
    
    log    STEP 3: start vca join ip with not flow ip, ip changed, start traffic and check vca parameter display correctly
    cli    eutA    clear vca counters all  
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream3    subscriber_p1    service_p1    ${service_vlan2}    &{tg_ds_param2}
    log    start vca join ip with not flow, ip changed 
    cli    eutA    start vca join ip ${vca_ip2} vlan ${service_vlan2} duration ${dur_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    show vca and check its rx-packets correctly 
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA
    Wait Until Keyword Succeeds    2min    5s    check_igmp_multicast_group_summary    eutA    ${vca_ip2}    ${service_vlan2}    ${igmp_param.interface}
    
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    cli    eutA    stop vca now

    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    clear vca counter before send traffic
    cli    eutA    clear vca counters all
    log    prov vlan with type n:1, service_point add svc
    prov_vlan    eutA    ${service_vlan}
    prov_vlan    eutA    ${service_vlan2}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    service_point remove_svc and deprovision
    cli    eutA    clear vca counters all
    Run Keyword And Ignore Error    service_point_remove_vlan    service_point_list1    ${service_vlan2}
    Run Keyword And Ignore Error    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan2}
    delete_config_object    eutA    vlan    ${service_vlan}
    Tg Delete All Traffic    tg1