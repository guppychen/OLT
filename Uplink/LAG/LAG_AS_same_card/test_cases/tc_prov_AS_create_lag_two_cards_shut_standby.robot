*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_AS_lag_two_cards_shut_standby
    [Documentation]    prov as lag two cards shut standby
    [Tags]    @globalid=2353717    @tcid=AXOS_E72_PARENT-TC-2341   @subfeature=LAG_Active_Standby_Same_Card    @priority=P1    @eut=NGPON2-4
    [Setup]    case setup


    lag_mem_status    eutA    ${la1}    ${service_model.service_point1.member.interface1}    ${eth_port_status}
    lag_mem_status    eutB    ${la1}    ${service_model.service_point2.member.interface1}    ${eth_port_status}
    
    eth_port_prov    eutA    ${service_model.service_point3.member.interface1}    shut
    lag_mem_status    eutA    ${la2}    ${service_model.service_point3.member.interface1}    ${eth_port_status_down}
    
    eth_port_prov    eutA    ${service_model.service_point3.member.interface1}    no shut
    lag_mem_status    eutA    ${la2}    ${service_model.service_point3.member.interface1}    ${eth_port_status}


    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown

lag_prov
    [Arguments]    ${eut}    ${lag_no}    ${lacp_mode}    ${max_port}    ${min_port}    ${hash_mode}='src-dst-ip'
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter la ${lag_no}
    cli    ${eut}    switchport enable
    cli    ${eut}    lacp-mode ${lacp_mode}
    cli    ${eut}    hash-method ${hash_mode}
    cli    ${eut}    max-port ${max_port}
    cli    ${eut}    min-port ${min_port}
    cli    ${eut}    no shut
    cli    ${eut}    end

lag_inter_prov
    [Arguments]    ${eut}    ${eth_port_1}    ${lag_no}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter eth ${eth_port_1}
    cli    ${eut}    no shut
    cli    ${eut}    role lag
    cli    ${eut}    group ${lag_no}
    cli    ${eut}    end


eth_port_prov
    [Arguments]    ${eut}    ${eth_port}    ${port_status}
    [Tags]    @author=Sewang
    ${re}    cli    ${eut}    config
    ${re}    cli    ${eut}    inter eth ${eth_port}
    ${re}    cli    ${eut}    ${port_status}
    ${re}    cli    ${eut}    end
    
lag_mem_status
    [Arguments]    ${eut}    ${la}    ${eth_port}    ${eth_port_status}
    [Tags]    @author=Sewang
    ${re}    cli    ${eut}    show inter la ${la} mem
    should contain    ${re}    ${eth_port}
    should contain    ${re}    ${eth_port_status}