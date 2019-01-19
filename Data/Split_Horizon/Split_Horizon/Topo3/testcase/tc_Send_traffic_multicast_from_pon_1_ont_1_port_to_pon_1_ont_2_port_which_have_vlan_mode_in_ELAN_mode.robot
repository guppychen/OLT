*** Settings ***
Documentation     Verify that multicast packets can be received on ont-2 port when traffic send from pon-1 ont 1 port to pon-1 ont 2 port which have vlan mode in ELAN mode.
Resource          ./base.robot
Force Tags        @feature=split_horizon    @subfeature=split_horizon

*** Variables ***


*** Test Cases ***
tc_Send_traffic_multicast_from_pon_1_ont_1_port_to_pon_1_ont_2_port_which_have_vlan_mode_in_ELAN_mode
    [Documentation]    Verify that multicast packets can be received on ont-2 port when traffic send from pon-1 ont 1 port to pon-1 ont 2 port which have vlan mode in ELAN mode.
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-407    @globalid=2263607    @eut=NGPON2-4    @priority=P2
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:Verify that multicast packets can be received on ont-2 port when traffic send from pon-1 ont 1 port to pon-1 ont 2 port which have vlan mode in ELAN mode.

    log    send traffic from ONT-1 of PON-1 to ONT-2 of PON-1.(multicast traffic)
    Tg Create Single Tagged Stream On Port    tg1    stream1    subscriber_p2    subscriber_p1    vlan_id=${p_match_vlan1}    vlan_user_priority=0
    ...    mac_dst=${subscriber_mac4}    mac_src=${subscriber_mac1}    rate_pps=${rate_pps}    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_dst_addr=${subscriber_ip4}    ip_src_addr=${subscriber_ip1}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63

    log    check all traffic can pass
    Tg Start All Traffic     tg1
    # wait to run
    sleep    ${sleep_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    stream1    ${loss_rate}


*** Keywords ***
setup
    [Documentation]    setup
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    mac-learning=enable    mode=ELAN

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