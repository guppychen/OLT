*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_When_ONT_is_off_line_show_default_ONT_detail
    [Documentation]
      
    ...    1	Show ont * detail	sucessfully		
    ...    2	Check PSE Management Ownership	No shows		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4331      @globalid=2531516      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    template_when_ONT_is_off_line_show_default_ONT_detail
    eutA    subscriber_point1

    
