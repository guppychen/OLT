*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm deletion flow under policy-map/class-map.
*** Variables ***

*** Test Cases ***
tc_provision_up_to_8_flow_under_policy_map
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision 8 flows under policy map/class-map, confirm provision works fine.		
    ...    2	Delete all the flows from policy-map/class-map, confirm deletion works fine.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1015    @globalid=2316477    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1015 setup
    [Teardown]   AXOS_E72_PARENT-TC-1015 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision 8 flows under policy map/class-map, confirm provision works fine.

    log    STEP:2 Delete all the flows from policy-map/class-map, confirm deletion works fine.


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     2    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     3    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     4    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     5    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     6    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     7    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     8    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    2    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    3    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    4    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    5    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    6    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    7    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    8    1    any=${EMPTY}
    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    policy-map ${policy_map_name}
    should contain    ${result}    class-map-ethernet ${class_map_name_check}


    log    provision flow 1 with add-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    add-cevlan-tag=${p_match_vlan1}    set-ctag-pcp=${ctag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    add-cevlan-tag\\s+${p_match_vlan1}
    should match regexp    ${result}    set-ctag-pcp\\s+${ctag_pcp}


    log    provision flow 2 with remove-cevlan
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     2    remove-cevlan=${EMPTY}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    remove-cevlan




    log    provision flow 3 with set-cevlan-pcp
    log    check set-cevlan-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     3    set-cevlan-pcp=${cetag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-cevlan-pcp\\s+${cetag_pcp}


    log    provision flow 4 with set-ctag-pcp
    log    check set-ctag-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     4    set-ctag-pcp=${ctag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-ctag-pcp\\s+${ctag_pcp}



    log    provision flow 5 with set-stag-pcp
    log    check set-stag-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     5    set-stag-pcp=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-stag-pcp\\s+${stag_pcp}


    log    provision flow 6 with translate-cevlan-tag
    log    check translate-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     6    translate-cevlan-tag=${p_data_vlan1}
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 6
    should match regexp    ${result}    translate-cevlan-tag\\s+${p_data_vlan1}



    log    provision flow 7 with translate-cevlan-tag and set s tag
    log    check translate-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     7    translate-cevlan-tag=${p_data_vlan1}    set-stag-pcp=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 7
    should match regexp    ${result}    translate-cevlan-tag\\s+${p_data_vlan1}
    should match regexp    ${result}    set-stag-pcp\\s+${stag_pcp}


    log    provision flow 8 with translate-cevlan-tag and set c tag
    log    check translate-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     8    translate-cevlan-tag=${p_data_vlan1}    set-stag-pcp=${ctag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 8
    should match regexp    ${result}    translate-cevlan-tag\\s+${p_data_vlan1}
    should match regexp    ${result}    set-stag-pcp\\s+${ctag_pcp}

    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=1
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 1
    should not contain    ${result}    add-cevlan-tag
    should not contain    ${result}    set-ctag-pcp

    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=2
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 2
    should not contain    ${result}    remove-cevlan

    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=3
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 3
    should not contain    ${result}    set-cevlan-pcp

    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=4
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 4
    should not contain    ${result}    set-ctag-pcp


    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=5
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 5
    should not contain    ${result}    set-stag-pcp

    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=6
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 6
    should not contain    ${result}    translate-cevlan-tag

    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=7
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 7
    should not contain    ${result}    set-stag-pcp


    log    delete flow from policy-map and check result
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=8
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 8
    should not contain    ${result}    set-stag-pcp



*** Keyword ***
AXOS_E72_PARENT-TC-1015 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1015 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

