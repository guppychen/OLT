*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_create_vlan_type_with_n_1_vlan
    [Documentation]    check it can works fine    
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4565      @globalid=2533289      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    STEP 1: start traffic, start vca join ip and check vca parameter display correctly
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream1    subscriber_p1    service_p1    ${service_vlan}    &{tg_ds_param1}
    log    show vca and check its rx-packets correctly   
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan} duration ${dur_time}
    
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA
    
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    cli    eutA    stop vca now
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    
    log    STEP 2: start traffic, start vca join ip with vlan mode change and check vca parameter display correctly
    log    change vlan type with 1:1 and check vca again
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
    log    clear vca counter before send traffic
    cli    eutA    clear vca counters all  
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream2    subscriber_p1    service_p1    ${service_vlan}    &{tg_ds_param1}
    log    show vca and check its rx-packets correctly 
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan} duration ${dur_time}
    
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA
    
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
    prov_vlan    eutA    ${service_vlan}    mode=N2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    service_point remove_svc and deprovision
    cli    eutA    clear vca counters all
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
    Tg Delete All Traffic    tg1
