*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Modify_default_ont_profile
    [Documentation]
      
    ...    1	Modify each parameter of ont-profile 814G	rejected		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4675      @globalid=2533405      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    template_modify_default_ont_profile
    eutA    subscriber_point1    ${status_disabled}

