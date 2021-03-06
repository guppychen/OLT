*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
Documentation     This test case is to confirm VLAN tagged traffic with specific Ethertype works with match rule match VLAN plus Ethertype. VLAN tagged but different Ethertype traffic will be dropped.
*** Variables ***

*** Test Cases ***
tc_Inject_VLAN_tagged_traffic_with_Match_Ethertype_RLT_SR_2492
    [Documentation]
    ...    1	Provision match rule match VLAN plus Ethertype (say 0x8863), confirm provision complete.
    ...    2	Inject VLAN tagged traffic with Ethertype 0x8863, confirm the traffic passes through.
    ...    3	Inject VLAN tagged traffic but different Ethertype (e.g. 0x8864), confirm the traffic is dropped.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-962    @globalid=2316420    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-962 setup
    [Teardown]   AXOS_E72_PARENT-TC-962 teardown
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision match rule match untagged plus Ethertype (say 0x8863), confirm provision complete.

    log    STEP:2 Inject untagged traffic with Ethertype 0x8863, confirm the traffic passes through.

    log    STEP:3 Inject untagged traffic but different Ethertype (e.g. 0x8864), confirm the traffic is dropped. EXA-21605 ppp session also can pass. Sent ipv4 packet to check if it will drop.
    log    due to EXA-19953. vlan + ethertype is not supported. vlan + 8863 traffic would be blocked.

    log    STEP:1. match rules: match ethertype;
    log    serivce 1
    log    configure class-map match ethertype success
    prov_class_map    eutA    ${class_map_name_ethertype}    ethernet    flow     1    1    ethertype=${rule_ethertype_pppdisc}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_ethertype}    flow     1    set-stag-pcp=${stag_pcp}
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}



    log    run traffic
    ${port_list}    create list    service_p1    subscriber_p1
    log    create upstream traffic

    log    traffic with udp
    log    untag traffic
    create_raw_traffic_udp    tg1    up_untag    service_p1    subscriber_p1
    ...    frame_size=512    length_mode=fixed    mac_dst=${service_mac}    mac_src=${subscriber_mac1}    ip_dst=${sip}    ip_src=${cip}
    ...    rate_mbps=${rate_pps1}



    log    traffic match_eth
    Tg Create Single Tagged Stream On Port    tg1     up_eth_match    service_p1    subscriber_p1    ${p_data_cvlan1}    ${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_src=${subscriber_mac1}    mac_dst=${service_mac}    ether_type=${traffic_ether_type_pppdisc}
    ...    rate_pps=${rate_pps1}

    log    traffic unmatch_eth
    Tg Create Single Tagged Stream On Port    tg1     up_eth_unmatch    service_p1    subscriber_p1    ${p_data_cvlan1}    ${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_src=${subscriber_mac1}    mac_dst=${service_mac}    ether_type=${traffic_ether_type_pppsession}
    ...    rate_pps=${rate_pps1}


    log    create downstream traffic
    log     traffic with udp

    log    traffic with vlan ${p_data_vlan1}
    create_raw_traffic_udp    tg1    down1    subscriber_p1    service_p1    ovlan=${p_data_vlan1}    ovlan_pbit=${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_dst=${subscriber_mac1}    mac_src=${service_mac}    ip_dst=${cip}    ip_src=${sip}
    ...    rate_mbps=${rate_pps1}



    log    run traffic

    log    learn arp
    Tg Start All Traffic    tg1
    sleep    ${learn_arp_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1

    log    run traffic and start stats
    Tg Start All Traffic     tg1
    Tg Packet Control    tg1    ${port_list}    start
    log    sleep for capturing enough packets
    sleep    ${run_traffic_time}
    Tg Packet Control    tg1    ${port_list}    stop
    Tg Stop All Traffic    tg1
    log    sleep for stop working
    sleep    ${wait_stop_time}
    Tg Save Config Into File    tg1     /tmp/stream.xml

    log    verify no traffic loss
    log    EXA-19953

    log    verify unmatch traffic lost
    log    PREM-22099 PREM-22168
    verify_traffic_all_loss_for_stream    tg1    up_eth_match
    verify_traffic_all_loss_for_stream    tg1    up_eth_unmatch







*** Keyword ***
AXOS_E72_PARENT-TC-962 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side
    prov_vlan    eutA    ${p_data_vlan1}
    prov_vlan    eutA    ${p_data_vlan2}
    prov_vlan    eutA    ${p_data_vlan3}

    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


AXOS_E72_PARENT-TC-962 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1

    log    delete svc
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ethernet ${class_map_name_ethertype}

    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}
    delete_config_object    eutA    vlan    ${p_data_vlan2}
    delete_config_object    eutA    vlan    ${p_data_vlan3}
