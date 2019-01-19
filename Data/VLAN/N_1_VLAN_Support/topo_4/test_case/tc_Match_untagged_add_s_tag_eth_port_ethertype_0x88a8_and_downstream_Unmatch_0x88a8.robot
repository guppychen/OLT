*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Match_untagged_add_s_tag_eth_port_ethertype_0x88ab_and_downstream_Unmatch_0x88a8
    [Documentation]    1	create a class-map to match untagged in flow 1
    ...    2	create a policy-map to bind the class-map
    ...    3	set eth-port1 ethertype=0x88a8
    ...    4	add eth-port1 to s-tag with transport-service-profile
    ...    5	apply the s-tag and policy-map to the port of ont1 and ont2
    ...    6	send single-tagged downstream to eth-port1； the traffic ethertype=0x9100	no clients can receive the traffics
    [Tags]    @author=AnneLI    @globalid=2298771    @tcid=AXOS_E72_PARENT-TC-661     @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5: send single-tagged downstream to ${interface_type1} ${service_model.service_point1.member.interface1},the traffic ethertype=0x9100;
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    p2    p1      vlan_id=${service_vlan}    vlan_user_priority=0    vlan_tpid=37120
    ...    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}
    ...    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
    ...    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p2
    start_capture    tg1    p3
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p2
    stop_capture    tg1    p3
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    verify traffic
    verify_no_traffic_on_port_with_filter    tg1    p2    eth.src==${mac2} and eth.dst==${mac1}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac2} and eth.dst==${mac1}

    [Teardown]    teardown
*** Keywords ***
setup
     [Documentation]    setup
     clear_bridge_table    eutA
     log     step3: set eth-port1 ethertype=0x88a8
     prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    ethertype=0x88a8
     log     step4: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match untagged in flow 1
     log     step2: create a policy-map to bind the class-map
     log     step5: apply the s-tag and policy-map to the port of ont1 and ont2
     subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan}     cfg_prefix=auto1
     subscriber_point_add_svc    subscriber_point2    untagged    ${service_vlan}     cfg_prefix=auto2
     CLI    eutA    show running-config

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan}     cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    untagged    ${service_vlan}     cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    dprov_interface_ethernet     eutA    ${service_model.service_point1.member.interface1}    ethertype
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    log    wait ${ont_delte_configure_time} to delte ont configure
    sleep    ${ont_delte_configure_time}
    CLI    eutA    show running-config



