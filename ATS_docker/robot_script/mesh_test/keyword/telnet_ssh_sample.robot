*** Settings ***
Library    Telnet
Library    SSHLibrary
Library    String

*** Variables ***

*** Keywords ***

cli
    [Arguments]    ${Device}    ${Command}    @{other_agrs}
    log    ${other_agrs}
    ${other_agrs}=    Convert To String    ${other_agrs}
    ${other_agrs}=    Remove String    ${other_agrs}    [    ]
    ${prompt_arg}=    Fetch From Right    ${other_agrs}    prompt=
    ${prompt_arg}=    Fetch From left    ${prompt_arg}    '
    ${timeout_arg}=    Fetch From Right    ${other_agrs}    timeout=
    ${timeout_arg}=    Fetch From left    ${timeout_arg}    '
    ${result_1}=    Run Keyword If    '${DEVICES.${Device}.protocol}'=='telnet'    cli_telnet    ${Device}    ${Command}    ${timeout_arg}    ${prompt_arg}
    ${result_2}=    Run Keyword If    '${DEVICES.${Device}.protocol}'=='ssh'    cli_ssh    ${Device}    ${Command}    ${timeout_arg}    ${prompt_arg}
    ${result_3}=    Run Keyword If    '${DEVICES.${Device}.protocol}'=='serial'    cli_serial    ${Device}    ${Command}    ${timeout_arg}    ${prompt_arg}
    ${result}=     Catenate    SEPARATOR=    ${result_1}    ${result_2}    ${result_3}
    ${result}=    Remove String    ${result}    NoneNone
    log    ${result}
    RETURN    ${result}

cli_serial
    [Arguments]    ${Device}    ${Command}    ${timeout}    ${prompt}
    pyserial.open_serial_connection    port=${DEVICES.${Device}.comPort}    boud=${DEVICES.${Device}.baud_num}
    log    ${Command}
    ${result}=    pyserial.command_enter    \n
    sleep    1
    ${result}=    pyserial.read_all_data
    ${result}=    pyserial.command_enter    ${Command}
    log    ${prompt}
    ${result}=    pyserial.read_until_print_result    ${prompt}
    log    ${result}
    pyserial.close_Serial_Port
    RETURN    ${result}

cli_ssh
    [Arguments]    ${Device}    ${Command}    ${timeout}    ${prompt}
	Log To Console		${DEVICES.${Device}.ip}
	#for ubuntu pc ssh
    #SSHLibrary.Open Connection    ${DEVICES.${Device}.ip}    timeout=60    prompt=${DEVICES.${Device}.prompt}     port=${DEVICES.${Device}.port}
	#for DUT pc ssh
	SSHLibrary.Open Connection    ${DEVICES.${Device}.ip}    timeout=60    port=${DEVICES.${Device}.port}

	#for ubuntu pc ssh
    #SSHLibrary.Login    ${DEVICES.${Device}.user_name}    ${DEVICES.${Device}.password}    login_prompt=${DEVICES.${Device}.login_prompt}    password_prompt=${DEVICES.${Device}.password_prompt}
	#for DUT pc ssh
	SSHLibrary.Login    ${DEVICES.${Device}.user_name}		${EMPTY}
	
    Run Keyword If    '${prompt}'!=''    SSHLibrary.Set Client Configuration    prompt=${prompt}
    Run Keyword If    '${timeout}'!=''    SSHLibrary.Set Client Configuration    timeout=${timeout}

    ${result}=    SSHLibrary.Execute Command    ${Command}    timeout=${timeout}
    #${result}=    SSHLibrary.Write    ${Command}
    #${result}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    log    ${result}	
    RETURN    ${result}

cli_telnet
    [Arguments]    ${Device}    ${Command}    ${timeout}    ${prompt}
    Telnet.Open Connection    ${DEVICES.${Device}.ip}    timeout=60    prompt=${DEVICES.${Device}.prompt}     port=${DEVICES.${Device}.port}
    ${login_result}=    Telnet.Login    ${DEVICES.${Device}.user_name}    ${DEVICES.${Device}.password}    login_prompt=${DEVICES.${Device}.login_prompt}    password_prompt=${DEVICES.${Device}.password_prompt}
    Run Keyword If    '${timeout}'==''    Telnet.Set Timeout    ${DEVICES.${Device}.timeout}
    Run Keyword If    '${timeout}'!=''    Telnet.Set Timeout    ${timeout}
    ${result}=    Telnet.Read
    log    ${timeout}
    log    ${prompt}
    Run Keyword If    '${prompt}'!=''    Telnet.Set Prompt    ${prompt}
    log    ${Command}
    ${result}=    Telnet.Write    ${Command}
    sleep    2
    ${result}=    Run Keyword And Ignore Error    Telnet.Read Until Prompt
    sleep    2
    ${result_2}=    Telnet.Read
    ${result} =   Catenate    ${result}   ${result_2}
    log    ${result}
    Telnet.Close Connection
    RETURN    ${result}
