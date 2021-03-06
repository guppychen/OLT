*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***
${root_user}    root
${root_user_passwd}    root

*** Test Cases ***
tc_User_authorization_order_set_to_radius_if_up_else_local_secret_mismatch_e7support_password
    [Documentation]
      
    ...    1	User-authorization set to radius-if-up-else-local. Radius server is up. SECRET mismatch between radius server and E7 radius-cfg auth configuration. Login with root/root (only local). Use Telnet and SSH. Execute the show session command.	Verify that it is a local login.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-4768     @globalid=2534731      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 User-authorization set to radius-if-up-else-local. Radius server is up. SECRET mismatch between radius server and E7 radius-cfg auth configuration. Login with root/root (only local). Use Telnet and SSH. Execute the show session command. Verify that it is a local login. 
    prov_radius_server    euta_radius    ${radius_server}    secret=${invalid_secret}
    prov_aaa_authentication_order    euta_radius    radius-if-up-else-local 
        
    log    Telnet, login succeeds
    cli    euta_localsession    configure
    show_user_sessions_contain    euta_radius    ${root_user}
    Session destroy local    euta_localsession
    
    log    SSH, login succeeds
    cli    euta_localsession2    configure
    show_user_sessions_contain    euta_radius    ${root_user}
 
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    dprov valid server
    dprov_radius_server    euta_radius    ${radius_server} 
    log    prov RADIUS user    
    ${conn}=    Session copy info    euta_radius    user=${root_user}    password=${root_user_passwd}    protocol=telnet
    Session build local    euta_localsession    ${conn}     
    ${conn2}=    Session copy info    euta_radius    user=${root_user}    password=${root_user_passwd}    protocol=ssh
    Session build local    euta_localsession2    ${conn2}    
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Run Keyword And Ignore Error    Session destroy local    euta_localsession
    log    dprov invalid server
    dprov_radius_server    euta_radius    ${radius_server} 
    prov_radius_server    eutB_root    ${radius_server}    secret=${secret}    retry=${radius_retry}
    dprov_aaa_authentication_order    euta_radius    radius-if-up-else-local
