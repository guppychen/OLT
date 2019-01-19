*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision discard policy.
*** Variables ***

*** Test Cases ***
tc_provision_discard_policy_RLT_SR_2532_RLT_SR_2533_RLT_SR_2534
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision policy map, class-map, provision ingress meter, confirm color aware and yellow-action can be provisioned.		
    ...    2	Provision policy map, class-map, provision egress meter, confirm color aware and yellow-action can be provisioned.		
    ...    3	Provision policy map, class-map, provision egress shaper, confirm color aware and yellow-action can be provisioned.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1000    @globalid=2316462    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1000 setup
    [Teardown]   AXOS_E72_PARENT-TC-1000 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision policy map, class-map, provision ingress meter, confirm color aware and yellow-action can be provisioned.

    log    STEP:2 Provision policy map, class-map, provision egress meter, confirm color aware and yellow-action can be provisioned.

    log    STEP:3 Provision policy map, class-map, provision egress shaper, confirm color aware and yellow-action can be provisioned.


    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}

    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    policy-map ${policy_map_name}
    should contain    ${result}    class-map-ethernet ${class_map_name_check}

    log    provision policy with ingress meter yellow action
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    ingress meter-mef    yellow-action=DROP
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    yellow-action\\s+DROP





*** Keyword ***
AXOS_E72_PARENT-TC-1000 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1000 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

