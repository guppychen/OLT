*** Settings ***
Documentation     Custom Libarary for WI-297 User Support for making connection , making and deleting user and other required operations required in user support

*** Keywords ***
Make a Connection and Login
    [Arguments]    ${session_name}    ${user}    ${password}
    [Documentation]    This Keyword will Make a connection to the passed connection and Login in the device to execute a basic CLI like Show version.
    ...    Arguments are in order :
    ...    *Session_name*
    ...    *User*
    ...    *Password*
    [Tags]    @author=vduraira
    ${conn}    Session copy info    n1    user=${user}    password=${password}
    Session build local    ${session_name}    ${conn}
    cli    ${session_name}    show version    #    30

Telnet Login
    [Arguments]    ${device}    ${user}    ${password}
    [Documentation]    Make a telnet connection the device which is passed int the keyword.
    ...    Control the shell using *h1* after that the keyword.
    ...
    ...    Arguments Accepted :
    ...    *device_name*
    ...    *user*
    ...    *password*
    [Tags]    @author=vduraira
    cli    n1    telnet ${device}    prompt=login:    timeout_exception=0
    cli    n1    ${user}    \    timeout_exception=0
    cli    n1    ${password}    \    timeout_exception=0

Make User in the Device
    [Arguments]    ${device}    ${user}    ${password}    ${role}
    [Documentation]    Make a User
    ...    Make a user in the device with given username and password.
    ...    Note: User role will be Oper by default.
    ...    Arguments Accepted :
    ...    *device_name* , *user* , *password*
    [Tags]    @author=vduraira
    cli    ${device}    cli
    cli    ${device}    conf
    cli    ${device}    aaa user ${user} password ${password} role ${role}
    Result Should Not Contain    error
    Disconnect    ${device}

Delete User in the Device
    [Arguments]    ${device}    ${user}
    [Documentation]    Delete a User
    ...    Delete a user in the device with given username and password.
    ...    Note: User role will be Oper by default.
    ...    Arguments Accepted :
    ...    *device_name* , *user* , *password*
    [Tags]    @author=vduraira
    cli    ${device}    cli
    cli    ${device}    conf
    cli    ${device}    no aaa user ${user}
    Result Should Not Contain    error
    Disconnect    ${device}

Make a Connection
    [Arguments]    ${session_name}    ${user}    ${password}
    [Documentation]    This Keyword will Make a connection to the passed connection .
    ...    Arguments are in order :
    ...    *Session_name*
    ...    *User*
    ...    *Password*
    [Tags]    @author=vduraira
    ${conn}    Session copy info    n1    user=${user}    password=${password}
    Session build local    ${session_name}    ${conn}
