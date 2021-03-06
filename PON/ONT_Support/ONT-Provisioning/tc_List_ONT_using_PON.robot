*** Settings ***
Documentation     ONT Provision test case
...    Preconditions:
...     1. ONTs Should be connected and deifined correctly in parameter file.
Resource          ./base.robot
Force Tags    @eut=NGPON2-4

*** Test Cases ***
List_ONT_using_PON
    [Documentation]    List ONT by using Provisioned PON
    [Tags]    @feature=ONT Support    @subFeature=ONT operation support    @author=Doris He    @author=<kkandra> Kumari    @tcid=AXOS_E72_PARENT-TC-489
    Cli   n1    config

    #Step1: Enable PON port
    Enable Port    n1    ${PORT.porttype}    ${PORT.gponport}
    #  ***  time to PON to come up and discover the ONT connected  ***
    Sleep    20
    Cli    n1    do show discovered-ont sum
    Result Should Contain    ${ONT.ontSerNum}

    #Step2: Provision ONT
    Full ONT Provision   n1   ${ONT.ontNum}   ${ONT.ontProfile}   ${ONT.ontSerNum}    ${ONT.ontPort}    ${ONT.ontMACAdd}   ${ONT.ontSubId}

    #*** time to get ONT provisioning linked with discovered ONT  ***
    Sleep    5
    Wait Until Keyword Succeeds  60    5s   Show ont-link and Status   n1    ${ONT.ontNum}    ${ONT.ontPort}

    #Step3: List ONT using PON Port
    Cli    n1    do show run ont provisioned-pon 1/1/${ONT.ontPort}
    List ONT   n1

    [Teardown]    AXOS_E72_PARENT-TC-485-78 teardown    n1   ${ONT.ontNum}    ${ONT.ontProfile}    ${ONT.ontSerNum}    1/1/${ONT.ontPort}
    ...    ${ONT.ontMACAdd}    ${ONT.ontSubId}    ${PORT.porttype}    ${PORT.gponport}


