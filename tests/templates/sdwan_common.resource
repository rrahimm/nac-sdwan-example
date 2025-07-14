# SDWAN-as-code robot file (trimmed)

*** Settings ***
Library   pabot.PabotLib
Library   RequestsLibrary
Library   JSONLibrary
Library   Collections
Library   OperatingSystem
Library   String
Library   packaging.version

*** Variables ***
&{login_json}=   j_username=%{SDWAN_USERNAME}   j_password=%{SDWAN_PASSWORD}
&{headers}=   content-type=application/x-www-form-urlencoded

*** Keywords ***
Get SDWAN Manager Token
   Create Session   login   %{SDWAN_URL}   verify=${False}   disable_warnings=1   headers=${headers}
   ${log_level}=   Set Log Level   NONE
   ${response}=   Wait Until Keyword Succeeds   6x   10s   POST On Session   login   /j_security_check   data=${login_json}
   Set Log Level   ${log_level}
   ${r_token}=   Wait Until Keyword Succeeds   6x   10s   GET On Session   login   /dataservice/client/token
   ${cookie}=   Get from dictionary   ${response.headers}   set-cookie
   ${r_cookie}=   Split string   ${cookie}   separator=;
   Set Parallel Value For Key   manager_token   ${r_token.text}
   Set Parallel Value For Key   manager_cookie   ${r_cookie[0]}

Get SDWAN Manager Version
   ${response}=   Wait Until Keyword Succeeds   6x   10s   GET On Session   sdwan_manager   /dataservice/system/device/controllers   params=model=vmanage
   ${r_version}=   Get Value From Json   ${response.json()}   $.data[0].version
   Set Parallel Value For Key   manager_version   ${r_version[0]}

Login SDWAN Manager
   Run Only Once   Get SDWAN Manager Token
   ${manager_token}=   Get Parallel Value For Key   manager_token
   ${manager_cookie}=   Get Parallel Value For Key   manager_cookie
   ${m_headers}=   Create Dictionary   X-XSRF-TOKEN=${manager_token}   Cookie=${manager_cookie}   accept=application/json
   Create Session   sdwan_manager   %{SDWAN_URL}   headers=${m_headers}
   Run Only Once   Get SDWAN Manager Version

Logout SDWAN Manager
   ${manager_cookie}=   Get Parallel Value For Key   manager_cookie
   ${m_headers}=   Create Dictionary   Cookie=${manager_cookie}   accept=*/*
   ${manager_version}=   Get Parallel Value For Key   manager_version
   ${version_check}=   Evaluate   packaging.version.Version('${manager_version}') >= packaging.version.Version('20.12')
   IF   ${version_check}
       ${response}=   Wait Until Keyword Succeeds   6x   10s   POST On Session   sdwan_manager   /logout   headers=${m_headers}
   ELSE
       ${response}=   Wait Until Keyword Succeeds   6x   10s   GET On Session   sdwan_manager   /logout   headers=${m_headers}
   END

Should Be Equal Value Json String
   [Arguments]   ${json}    ${json_path}   ${value}=${EMPTY}  ${msg}=${EMPTY}
   ${r_value}=   Get Value From Json   ${json}   ${json_path}
   ${r_value}=   Set Variable If    ${r_value} == []    not_defined    ${r_value[0]}
   Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal As Strings    ${r_value}    ${value}    values=False    msg=${msg} expected: '${value}' and got: '${r_value}'  
