*** Settings ***
Documentation     
Resource          ./base.robot


*** Variables ***
${rmon_session}    fifteen-minutes
${bin_count}     4

*** Test Cases ***
tc_Each_PON_OLT_Interface_MUST_support_collection_of_a_Per_ONU_basis_Upstream_Missed_Bursts
    [Documentation]    Each PON OLT Interface MUST support collection of Upstream Physical Layer Statistics on a Per ONU basis: Upstream Missed Bursts
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-795    @globalid=2307655
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Each PON OLT Interface MUST support collection of Upstream Physical Layer Statistics on a Per ONU basis: Upstream Missed Bursts.

    ${output}    show_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_15_min}    ${rmon_type}    ${num_back}    ${num_show}
    Should Match Regexp    ${output}    upstream-missed-bursts \\d+


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
     prov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_15_min}     ${bin_count}
     
case teardown
    [Documentation]
    [Arguments]
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_15_min}     ${bin_count}