*** Settings ***
Documentation     Multiple DHCP Snoop Service Using Tag Actions on an Acces Interface
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Multiple_DHCP_Snoop_Service_Using_Tag_Actions_on_an_Acces_Interface
    [Documentation]    1	Multiple DHCP Snoop Service Using Tag Actions on an Acces Interface: Enable two services on access interface each with unique tag-action. Example: Add-tag and change-tag. Both services enabled for DHCP snooping. Force a subscriber from each service to obtain an IP address via DHCP. Display snooping table. -> Each client obtains an address. The client addresses are listed as a DHCP snoop entry.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-742    @globalid=2307086    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Multiple DHCP Snoop Service Using Tag Actions on an Acces Interface: Enable two services on access interface each with unique tag-action. Example: Add-tag and change-tag. Both services enabled for DHCP snooping. Force a subscriber from each service to obtain an IP address via DHCP. Display snooping table. -> Each client obtains an address. The client addresses are listed as a DHCP snoop entry. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    create_dhcp_server    tg1    ${server_name_2}    service_p1    ${server_mac_2}     ${server_ip_2}     ${lease_start_2}    ${Qtag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}    ${Qtag_vlan_2}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Control Dhcp Server    tg1    ${server_name_2}    start
    Tg Control Dhcp Client    tg1    ${group_name_2}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    wait until keyword succeeds    10    1    check_l3_hosts    eutA    2
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    create_bound_traffic_udp    tg1    dhcp_upstream2    subscriber_p1    ${server_name_2}    ${group_name_2}    10
    create_bound_traffic_udp    tg1    dhcp_downstream2    service_p1    ${group_name_2}    ${server_name_2}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}   
    prov_vlan    eutA    ${Qtag_vlan}    l2-dhcp-profile=${l2_profile_name}
    prov_vlan_egress    eutA    ${Qtag_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444
    service_point_add_vlan    service_point_list1    ${stag_vlan},${Qtag_vlan}    cfg_prefix=2 
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=2
    Cli With Error Check    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
    sleep    ${wait_ont_come_back_in_reality}

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name_2}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name_2}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name_2}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cfg_prefix=2
    service_point_remove_vlan    service_point_list1    ${stag_vlan},${Qtag_vlan}    cfg_prefix=2
    delete_config_object    eutA    vlan    ${Qtag_vlan}
    service_point_add_vlan    service_point_list1    ${stag_vlan}
