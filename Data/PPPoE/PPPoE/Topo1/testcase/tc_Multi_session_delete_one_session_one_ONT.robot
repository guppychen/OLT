*** Settings ***
Documentation     Multi session, delete one session (one ONT)
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_Multi_session_delete_one_session_one_ONT
    [Documentation]    Multi session, delete one session (one ONT)
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2374    @globalid=2356936    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Multi session, delete one session (one ONT)
    log    create PPPoE server and client on STC
    # wait the engine to start
    sleep    10
    TG Create Pppoe v4 Server On Port   tg1    ${server_name}    service_p1    encap=ethernet_ii_qinq    vlan_id=${p_match_vlan}    vlan_user_priority=0
    ...    vlan_id_outer=${p_data_vlan}    vlan_outer_user_priority=0    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port   tg1    ${client_name}    subscriber_p1    encap=ethernet_ii_vlan    vlan_id=${p_match_vlan}    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${client_mac}

    TG Create Pppoe v4 Server On Port   tg1    ${server_name2}    service_p1    encap=ethernet_ii_qinq    vlan_id=${p_match_vlan2}    vlan_user_priority=0
    ...    vlan_id_outer=${p_data_vlan2}    vlan_outer_user_priority=0    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port   tg1    ${client_name2}    subscriber_p1    encap=ethernet_ii_vlan    vlan_id=${p_match_vlan2}    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${client_mac2}
    Tg Save Config Into File    tg1     /tmp/${TEST NAME}.xml

    Tg Control Pppox By Name    tg1    ${server_name}    connect
    Tg Control Pppox By Name    tg1    ${client_name}    connect
    Tg Control Pppox By Name    tg1    ${server_name2}    connect
    Tg Control Pppox By Name    tg1    ${client_name2}    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${pppoe_negotiated_time}

    log    create upstream and downstream flow
    Tg Create Bound Untagged Stream On Port    tg1    upstream    subscriber_p1    ${server_name}    ${client_name}    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed
    Tg Create Bound Untagged Stream On Port    tg1    downstream    service_p1    ${client_name}    ${server_name}    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed

    Tg Create Bound Untagged Stream On Port    tg1    upstream2    subscriber_p1    ${server_name2}    ${client_name2}    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed
    Tg Create Bound Untagged Stream On Port    tg1    downstream2    service_p1    ${client_name2}    ${server_name2}    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed

    log    check all traffic can pass
    Tg Start All Traffic     tg1
    # wait time to make traffic stable
    sleep    ${sleep_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    Tg Save Config Into File    tg1     /tmp/stream.xml
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream2    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream2    ${loss_rate}

    log    delete the session MAC and VLAN (wrong MAC)
    delete_pppoe_session    eutA     ${p_data_vlan2}    ${client_mac2}
    log    The other session is still active and there is no packet loss
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${pppoe_negotiated_time}

    Tg Start All Traffic     tg1
    # wait time to make traffic stable
    sleep    ${sleep_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    Tg Save Config Into File    tg1     /tmp/stream.xml
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${loss_rate}
   # wait the engine to stop
    sleep    30

*** Keywords ***
case setup
    [Documentation]  setup
    [Arguments]
    log    create id-profile
    prov_id_profile    eutA    ${id_prf1}
    log    use the id-profile in VLAN 100 and 200
    prov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile=${id_prf1}    mac-learning=enable
    prov_vlan    eutA    ${p_data_vlan2}    pppoe-ia-id-profile=${id_prf1}    mac-learning=enable
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan},${p_data_vlan2}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan2}    ${p_data_vlan2}    cfg_prefix=auto2


case teardown
    [Documentation]  teardown
    [Arguments]
    Tg Control Pppox By Name    tg1    ${client_name}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name}    disconnect
    Tg Control Pppox By Name    tg1    ${client_name2}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name2}    disconnect
    sleep    30s    Sleep for tg operation time
    log    teardown
    Run Keyword And Continue On Failure    TG Delete PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1
    Run Keyword And Continue On Failure    TG Delete PPPoE v4 Server On Port    tg1    ${server_name}    service_p1
    Run Keyword And Continue On Failure    TG Delete PPPoE v4 Client On Port    tg1    ${client_name2}    subscriber_p1
    Run Keyword And Continue On Failure    TG Delete PPPoE v4 Server On Port    tg1    ${server_name2}    service_p1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan2}    ${p_data_vlan2}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_data_vlan},${p_data_vlan2}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    vlan    ${p_data_vlan2}
    delete_config_object    eutA    id-profile    ${id_prf1}

