*** Settings ***
Force Tags        @feature=VLAN    @author=Anson Zhang
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Match_VLAN_remove_cevlan
    [Documentation]    1 create a class-map to match VLAN 10 in flow 1 successfully
    ...    2 create a policy-map to bind the class-map and remove-cevlan successfully
    ...    3 add eth-port1 to s-tag with transport-service-profile successfully
    ...    4 apply the s-tag and policy-map to the uni ethernet port successfully
    ...    5 send VLAN 10 upstream traffic to uni ethernet port with SMAC 000001000001 DMAC 000002000002; eth-port1 can pass the upstream traffic
    ...    6 send single-tagged downstream traffic to eth-port1 with SMAC 000002000002 DMAC 000001000001; client can receive the downstream traffic;
    [Tags]    @tcid=AXOS_E72_PARENT-TC-4382    @subFeature=VLAN mapping: change C-Tag to an S-Tag    @globalid=2532638    @priority=P1    @eut=10GE-12    @user_interface=CLI
    ...    @PASS=true
    [Setup]    case setup
    log    STEP:1 create a class-map to match VLAN 10 in flow 1 successfully
    log    STEP:2 create a policy-map to bind the class-map and remove-cevlan successfully
    log    STEP:3 add eth-port1 to s-tag with transport-service-profile successfully
    log    STEP:4 apply the s-tag and policy-map to the uni ethernet port successfully
    log    STEP:5 send VLAN 10 upstream traffic to uni ethernet port with SMAC 000001000001 DMAC 000002000002; eth-port1 can pass the upstream traffic
    log    STEP:6 send single-tagged downstream traffic to eth-port1 with SMAC 000002000002 DMAC 000001000001; client can receive the downstream traffic;
    run_dhcp_and_check_traffic    dserver    dcg    service_p1    subscriber_p1    traffic_loss_rate=${p_traffic_loss_rate}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create vlan
    prov_vlan    eutA    ${p_service_vlan}
    prov_vlan_egress    eutA    ${p_service_vlan}    broadcast-flooding    ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_service_vlan}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cevlan_action=remove-cevlan
    log    create dhcp server and client
    create_dhcp_server    tg1    dserver    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.startup_ip}
    ...    ovlan=${p_service_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${p_dhcp_client.mac}    ovlan=${p_match_vlan}

case teardown
    log    delete the tg server and client
    Tg Delete All Traffic    tg1
    Tg Delete Dhcp Client    tg1    dclient
    Tg Delete Dhcp Server    tg1    dserver
    log    remvoe service from uni port
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_service_vlan}
    log    delete vlan and profile
    delete_config_object    eutA    vlan    ${p_service_vlan}
