*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
Documentation     This test case is to confirm priority-tagged traffic works with match rule match priority-tagged, and all the other than priority-tagged traffic will be dropped.
*** Variables ***

*** Test Cases ***
tc_Inject_priority_tagged_traffic_with_match_priority_tagged_RLT_SR_2486
    [Documentation]
    ...    #	Action	Expected Result	Notes
    ...    1	Provision match rule match priority-tagged, confirm provision complete.
    ...    2	Inject priority-tagged traffic, confirm the traffic passes through.
    ...    3	Inject not-priority-tagged traffic, confirm the traffic is dropped.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-952    @globalid=2316410    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-952 setup
    [Teardown]   AXOS_E72_PARENT-TC-952 teardown
    log    STEP:

    log    STEP:1 Provision match rule match untagged, confirm provision complete.

    log    STEP:2 Inject untagged traffic, confirm the traffic passes through.

    log    STEP:3 Inject not-untagged traffic, confirm the traffic is dropped.


    log    STEP:1. match rules: priority tag;
    log    serivce 1
    log    configure class-map match priority success
    prov_class_map    eutA    ${class_map_name_priority}    ethernet    flow     1    1    priority-tagged=${EMPTY}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_priority}    flow     1    set-stag-pcp=${stag_pcp}
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}


    log    run traffic
    ${port_list}    create list    service_p1    subscriber_p1
    log    create upstream traffic

    log    traffic with udp
    log    untag traffic
    create_raw_traffic_udp    tg1    up_untag    service_p1    subscriber_p1
    ...    frame_size=512    length_mode=fixed    mac_dst=${service_mac}    mac_src=${subscriber_mac1}    ip_dst=${sip}    ip_src=${cip}
    ...    rate_mbps=${rate_pps1}


    log    tag traffic
    create_raw_traffic_udp    tg1    up_tag    service_p1    subscriber_p1    ovlan=${p_data_cvlan1}
    ...    frame_size=512    length_mode=fixed    mac_dst=${service_mac}    mac_src=${subscriber_mac1}    ip_dst=${sip}    ip_src=${cip}
    ...    rate_mbps=${rate_pps1}


    log    priority traffic
    create_raw_traffic_udp    tg1    up_pri    service_p1    subscriber_p1    ovlan=${p_match_remove}    ivlan=${p_data_cvlan2}
    ...    frame_size=512    length_mode=fixed    mac_dst=${service_mac}    mac_src=${subscriber_mac1}    ip_dst=${sip}    ip_src=${cip}
    ...    rate_mbps=${rate_pps1}

    log    create downstream traffic
    log     traffic with udp

    log    traffic with vlan ${p_data_vlan1}
    create_raw_traffic_udp    tg1    down1    subscriber_p1    service_p1    ovlan=${p_data_vlan1}    ovlan_pbit=${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_dst=${subscriber_mac1}    mac_src=${service_mac}    ip_dst=${cip}    ip_src=${sip}
    ...    rate_mbps=${rate_pps1}

    log    traffic with vlan ${p_data_vlan2}
    create_raw_traffic_udp    tg1    down2    subscriber_p1    service_p1    ovlan=${p_data_vlan1}    ovlan_pbit=${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_dst=${subscriber_mac1}    mac_src=${service_mac}    ip_dst=${cip}    ip_src=${sip}
    ...    rate_mbps=${rate_pps1}

    log    traffic with vlan ${p_data_vlan3}
    create_raw_traffic_udp    tg1    down3    subscriber_p1    service_p1    ovlan=${p_data_vlan1}    ovlan_pbit=${cetag_pcp}
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
    Tg Verify Traffic Loss For Stream Is Within    tg1    up_pri    ${loss_rate}
    log    EXA-21169
    log    verify unmatch traffic lost
    verify_traffic_all_loss_for_stream    tg1    up_tag




    ${p1_cap}    generate_pcap_name    combination_test_1
    Tg Store Captured Packets    tg1    service_p1    ${p1_cap}

    log    verify first streams packets
    wsk Load File    ${p1_cap}    vlan.id==${p_data_vlan1}
    Wsk Verify Outer Pbit    ${stag_pcp}





*** Keyword ***
AXOS_E72_PARENT-TC-952 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side
    prov_vlan    eutA    ${p_data_vlan1}
    prov_vlan    eutA    ${p_data_vlan2}
    prov_vlan    eutA    ${p_data_vlan3}

    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


AXOS_E72_PARENT-TC-952 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1


    log    delete svc
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ethernet ${class_map_name_priority}

    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}
    delete_config_object    eutA    vlan    ${p_data_vlan2}
    delete_config_object    eutA    vlan    ${p_data_vlan3}
