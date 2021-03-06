*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm error operation for flow under class-map.
...    Following is sample of error operation.
...     
...    * Try to delete flow that is referred by interface or VLAN.
...    * Try to delete non-existing flow.
...    * Try to modify match list incorrectly, for example, duplicate match rule, etc.
*** Variables ***

*** Test Cases ***
tc_error_operation_for_flow_RLT_SR_2531
    [Documentation]    	
    ...    #	Action	Expected Result	Notes
    ...    1	Try to execute error operation as described in description, confirm AXOS shows error properly.		
    ...    2	Try to execute error operation as described in description, confirm the system in same status as before operation (roll back).					
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-985    @globalid=2316447    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-985 setup
    [Teardown]   AXOS_E72_PARENT-TC-985 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes


    log    STEP:1 Try to execute error operation as described in description, confirm AXOS shows error properly.

    log    STEP:2 Try to execute error operation as described in description, confirm the system in same status as before operation (roll back).


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    set-stag-pcp=${stag_pcp}


    log    remove class-map referenced by policy map
    ${result}    delete_config_object_without_error_check    eutA    class-map    ethernet ${class_map_name_check}
    log    check the error message
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:

    log    remove flow not exist
    ${result}    dprov_class_map_without_error_check    eutA    ${class_map_name_check}    ethernet    flow    8    rule=1
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:

    log    remove rule not exist
    ${result}    dprov_class_map_without_error_check    eutA    ${class_map_name_check}    ethernet    flow    1    rule=10
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:

    log    remove class-map not exist
    ${result}    delete_config_object_without_error_check    eutA    class-map    ethernet ${class_map_name_noexist}
    log    check the error message
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:





*** Keyword ***
AXOS_E72_PARENT-TC-985 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-985 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

