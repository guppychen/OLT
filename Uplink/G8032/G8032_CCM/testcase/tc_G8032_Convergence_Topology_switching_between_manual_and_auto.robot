*** Settings ***
Documentation     The purpose of this test case is to verify CCM switching between manual and auto.
...               1.Check g8032 ring with ccm manual
...
...

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_G8032_Convergence_Topology_switching_between_manual_and_auto.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2008     @globalid=2329397    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]     The purpose of this test case is to verify CCM switching between manual and auto.
    ...               1.Check g8032 ring with ccm manual
    [Setup]      setup
    log     change wait-to-restore-time=1
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    wait-to-restore-time=1
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    wait-to-restore-time=1

    log     check g8032 status
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     success

    [Teardown]   teardown


*** Keywords ***
setup
    log     setup megs
    prov_meg           eutA    ${meg1}    ${mep1}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg1}    remote-mep=${mep3}
    prov_meg           eutA    ${meg2}    ${mep2}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg2}    remote-mep=${mep4}
    prov_meg           eutB    ${meg3}    ${mep3}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg3}    remote-mep=${mep1}
    prov_meg           eutB    ${meg4}    ${mep4}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg4}    remote-mep=${mep2}

    log      assign megs to ethernet ports
    prov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface1}     ${service_model.service_point1.name}     ${EMPTY}    mep     ${meg1}    ${mep1}
    prov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface2}     ${service_model.service_point1.name}     ${EMPTY}    mep     ${meg2}    ${mep2}
    prov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface1}     ${service_model.service_point2.name}     ${EMPTY}    mep     ${meg3}    ${mep3}
    prov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface2}     ${service_model.service_point2.name}     ${EMPTY}    mep     ${meg4}    ${mep4}


teardown
    log      unassign megs to ethernet ports
    dprov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface1}      g8032_ring=${service_model.service_point1.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface2}      g8032_ring=${service_model.service_point1.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface1}      g8032_ring=${service_model.service_point2.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface2}      g8032_ring=${service_model.service_point2.name}     ccm-protection=${EMPTY}

    log     remove ccm and then check g8032 status again
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log      delete megs
    delete_config_object    eutA    meg    ${meg1}
    delete_config_object    eutA    meg    ${meg2}
    delete_config_object    eutB    meg    ${meg3}
    delete_config_object    eutB    meg    ${meg4}

    log      provision ccm to G8032 ring

    prov_interface     eutA    ethernet    ${service_model.service_point1.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}       ccm-protection=auto
    prov_interface     eutA    ethernet    ${service_model.service_point1.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}       ccm-protection=auto
    prov_interface     eutB    ethernet    ${service_model.service_point2.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}       ccm-protection=auto
    prov_interface     eutB    ethernet    ${service_model.service_point2.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}       ccm-protection=auto

    log     check g8032 status with CCM auto

    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     remove ccm from interface interfaces
    dprov_interface     eutA    ethernet    ${service_model.service_point1.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}      ccm-protection=auto
    dprov_interface     eutA    ethernet    ${service_model.service_point1.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}      ccm-protection=auto
    dprov_interface     eutB    ethernet    ${service_model.service_point2.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}      ccm-protection=auto
    dprov_interface     eutB    ethernet    ${service_model.service_point2.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}      ccm-protection=auto
