*** Settings ***
Documentation     Verify that broadcast packets got dropped when traffic send from pon 1 ont 1 to pon 1 ont 2 which have vlan mode in N2ONE mode.
Resource          ./base.robot
Force Tags        @feature=split_horizon    @subfeature=split_horizon

*** Variables ***


*** Test Cases ***
tc_Send_traffic_broadcast_from_pon1_ont_1_to_pon1_ont_2_which_have_vlan_mode_in_N2ONE_mode
    [Documentation]    Verify that broadcast packets got dropped when traffic send from pon 1 ont 1 to pon 1 ont 2 which have vlan mode in N2ONE mode.
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-404    @globalid=2263604    @eut=NGPON2-4    @priority=P2
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:Verify that broadcast packets got dropped when traffic send from pon 1 ont 1 to pon 1 ont 2 which have vlan mode in N2ONE mode.

    log    send traffic from ONT-1 to ONT-2.(broadcast traffic)
    Tg Create Single Tagged Stream On Port    tg1    stream1    subscriber_p2    subscriber_p1    vlan_id=${p_match_vlan1}    vlan_user_priority=0
    ...    mac_dst=${subscriber_mac3}    mac_src=${subscriber_mac1}    rate_pps=${rate_pps}    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_dst_addr=${subscriber_ip3}    ip_src_addr=${subscriber_ip1}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63
    log    check no traffic can pass
    Tg Start All Traffic     tg1
    # wait to run
    sleep    ${sleep_time}
    tg save config into file   tg1   /tmp/split.xml

    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    ${res}    Tg Get Traffic Stats By Key On Stream    tg1    stream1    rx.total_pkts
    @{rx_pkts}    Get Dictionary Values    ${res}
    should be true    @{rx_pkts}[0]==0


*** Keywords ***
setup
    [Documentation]    setup
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    mac-learning=enable
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan2}    ${p_data_vlan}    cevlan_action=remove-cevlan    cfg_prefix=auto2



teardown
    [Documentation]    teardown
    run keyword and ignore error  tg delete all traffic    tg1

    log    subscriber_point remove_svc
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan2}    ${p_data_vlan}    cfg_prefix=auto2

    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan}

