*** Settings ***
Resource          ./base.robot

*** Variables ***
#${craft1}    1
#${craft2}    2
#${craft2_ip}    10.245.46.220
#${craft2_mask}    255.255.255.0
#${craft2_gateway}    10.245.46.1
#${craft2_ip_mask}    10.245.46.220/24

*** Test Cases ***
tc_prov_local_craft2
    [Documentation]    prov inter craft 2
    [Tags]    @author=Sean Wang    @globalid=2319905    @tcid=AXOS_E72_PARENT-TC-1324   @feature=Management    @subfeature=Local Craft Interface Support    @priority=P1
    [Setup]    case setup
    log    STEP:prov inter craft 2
    ${result}    cli    eutB    show inter craft
    should contain    ${result}    craft ${craft1}
    should contain    ${result}    craft ${craft2}
    prov_interface    eutB    craft    ${craft2}    no=shut
    prov_interface    eutB    craft    ${craft2}    ip address=${craft2_ip_mask} gateway ${craft2_gateway}
    Wait Until Keyword Succeeds    30 sec    10 sec    check craft connected    eutA    ${craft2}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    cli    eutB    paginate false
    cli    eutB    show inter craft ${craft2}

case teardown
    log    Enter case teardown
    cli    eutB    show inter craft ${craft2}
    
check craft connected
    [Arguments]    ${eut}    ${craft_no}
    ${result}    cli    ${eut}    show inter craft ${craft_no}
    should contain    ${result}    ${craft2_ip_mask}
    should contain    ${result}    ${craft2_gateway}
    should contain    ${result}    admin-state     enable
    
