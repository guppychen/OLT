*** Settings ***
Documentation     Static Subnet Host w/ MAC and Subnet Toggle with IPSV: Provision static host with a MAC and static subnet on same service. DHCP Snooping and IPSV are enabled. Generate bidirectional traffic the host and subnet subscriber. Remove subnet entry. Re-generate traffic. Re-add subnet entry. Re-generate traffic. -> Subnet traffic is only forwarded when subnet entry is present. Only host traffic is forwarded when subnet entry is removed.
...    SR Security Feature Interaction Config #3: Static, DHCP Snoop Disabled, MACFF Disabled, IPSV Enabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Static_Subnet_Host_w_MAC_and_Subnet_Toggle_with_IPSV
    [Documentation]    Static Subnet Host w/ MAC and Subnet Toggle with IPSV: Provision static host with a MAC and static subnet on same service. DHCP Snooping and IPSV are enabled. Generate bidirectional traffic the host and subnet subscriber. Remove subnet entry. Re-generate traffic. Re-add subnet entry. Re-generate traffic. -> Subnet traffic is only forwarded when subnet entry is present. Only host traffic is forwarded when subnet entry is removed.
    ...    SR Security Feature Interaction Config #3: Static, DHCP Snoop Disabled, MACFF Disabled, IPSV Enabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-597    @GlobalID=2286144    @EUT=NGPON2-4
    [Setup]      setup
    log    check static l3 host detail
    ${res}    cli    eutA    show l3|tab
    should match regexp    ${res}    ${service_vlan}\\s+${client_ip1}\\s+${mask32}\\s+${service_model.subscriber_point1.name}\\s+-\\s+${client_mac1}\\s+-\\s+${gateway1}
    should match regexp    ${res}    ${service_vlan}\\s+${client_subnet2}\\s+${mask24}\\s+${service_model.subscriber_point1.name}\\s+-\\s+${mac0}\\s+-\\s+${gateway2}
    log    create 2 streams match each ipv4 l2host, all can pass 100%
    create_raw_traffic_udp    tg1    matchip_up1    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac1}    mac_src=${client_mac1}    ip_dst=${gateway1}    ip_src=${client_ip1}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    matchip_up2    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac2}    mac_src=${client_mac2}    ip_dst=${gateway2}    ip_src=${client_ip2}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    10
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    log    delete static subnet, as static host has been delete before, this 2 matched streams cannot pass
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_subnet2}
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Verify Traffic Loss For Stream Is Within     tg1    matchip_up1     ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    matchip_up2
    log    delete static host with mac, this matched stream cannot pass, others pass 100%
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_ip1}
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    verify_traffic_stream_all_pkt_loss    tg1    matchip_up1
    verify_traffic_stream_all_pkt_loss    tg1    matchip_up2
    log    re-add static host, all streams pass 100% again
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_ip1}    mac ${client_mac1} gateway1 ${gateway1}
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_subnet2}    gateway1 ${gateway2} mask ${mask24}
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    [Teardown]   teardown



*** Keywords ***
setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision, change tag
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    log    provision 2 ipv4 l2 host on sub device, static host with mac, static subnet
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_ip1}    mac ${client_mac1} gateway1 ${gateway1}
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_subnet2}    gateway1 ${gateway2} mask ${mask24}



teardown
    Tg Delete All Traffic    tg1
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}