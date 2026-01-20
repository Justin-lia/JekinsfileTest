*** Settings ***
Library    Process
Library    OperatingSystem
Library    SerialLibrary
Library    SeleniumLibrary
Library    SSHLibrary
Library     String
Library     BuiltIn
Resource    ../../keyword/Variable.robot
Resource    ../base.robot
#Library     telnet_case.py

*** Test Cases ***

#Enable DUT controller SSH
#	Log		Enable controller SSH 		INFO
#	Enable controller SSH 

Agent roaming test
	[Tags]	mesh roaming test
	[Documentation]		1.Start capture wifi pack
	...					2.Agent roaming
	...					3.Stop capture wifi pack
	...					4.Confirm wifi roaming pack
	#Start capture wifi pack		${agent_bssid}
	Agent roaming
	#Stop capture wifi pack		${agent_bssid}

*** Keywords ***
Agent roaming
	[Tags]	mesh_test 
	[Documentation]		1.get agent upstream
	...					2.get/set att1 
	...					3.get/set att2
	...					4.Wait 60s
	...					5.Confirm ATT1/2 value
	...					6.Confirm agent upstream
	...					7.Return roaming status

	# get agent upstream
	${DUT_MAC}=	Set Variable	A8:C2:46:3D:39:68
	${agent1_upstream}=		Check Agent status		${DUT_MAC}

	Log To Console    Upstream is: ${agent1_upstream}

	#define att default value
	${ATT1_Value}=    Set Variable    ${0}
	${ATT2_Value}=    Set Variable    ${0}
	
	#Get ATT1 valur
	Log To Console	get ATT1 value
	${ATT1_value}=	get ATT value	ATT1
	Log To Console	get ATT1 value is ${ATT1_value}
	
	# setup ATT count value
	${ATT1_value}=	Evaluate    ${ATT1_Value} + 1
	Log To Console	Setup ATT1 to ${ATT1_value}
	set ATT value	ATT1	${ATT1_value}
	
	#Get ATT2 valur
	Log To Console	get ATT2 value
	${ATT2_value}=	get ATT value	ATT2
	Log To Console	get ATT2 value is ${ATT2_value}
	
	# setup ATT count value
	${ATT2_value}=	Evaluate    ${ATT2_Value} + 1
	Log To Console	Setup ATT2 to ${ATT2_value}
	set ATT value	ATT2	${ATT2_value}
	
	Log To Console	Wait 60s to roaming
	sleep	10s

	# Confirm ATT1/2 value
	${ATT1_Value}=		get ATT value	ATT1
	Log To Console		get ATT1 value is ${ATT1_value}
	${ATT2_Value}=		get ATT value	ATT2
	Log To Console		get ATT2 value is ${ATT2_value}
	
	# Check agent upstream
	${agent2_upstream}=		Check Agent status		A8:C2:46:3D:39:68
	Log To Console    Upstream is: ${agent1_upstream}

	# Return roaming status
	IF    '${agent2_upstream}' == '${agent1_upstream}'		Log To Console		"roaming success"    ELSE    Log To Console    "roaming fail"
	
get ATT value
	[Arguments]    ${ATT_number}
	RETURN		50

set ATT value
	[Arguments]    ${ATT_number}	${set_ATT_value}
	${set_ATT_value}	Evaluate	${set_ATT_value} + 5
	RETURN		${set_ATT_value}


Check Agent status
	[Arguments]    ${target_mac}
	[Documentation]	1.Input Agent mac
	...				2. Output Connect mac band 
	...				example: 
	...				Check Agent status		E4:C7:67:8A:8F:36
	...				return		10:7C:61:C0:BF:E2

	Log		Agent : ${target_mac}	INFO
	Log To Console		.
	
	${mesh_topology_json}=	get mesh topology from ssh
		
	##${json_string}=    OperatingSystem.Get File    test_suites/Mesh/topology.json
	
    ${data}=    Evaluate    json.loads('''${mesh_topology_json}''')    json
    
    ${result}=    Evaluate    [item['Upstream_device'] for item in $data['DB'] if item['Mac'] == '${target_mac}']

    # 因為結果會是一個 List，取出第一個元素
    #${upstream}=    Get From List    ${result}    0
	${status}    ${value}=    Run Keyword And Ignore Error    Get From List    ${result}    0

	IF    '${status}' == 'PASS'
        ${upstream}=    Set Variable    ${value}
    ELSE
        ${upstream}=    Set Variable    FAIL
    END	
	
	sleep	3s
    #Log To Console    Upstream is: ${upstream}
	RETURN		${upstream}

get mesh topology from ssh
	[Documentation]	Login to DUT and cat /tmp/.mesh_topo_info
	# ${DEVICES.DUT_LAN_SSH.user_name}
	# ${DEVICES.${Device}.user_name}
	# ${DEVICES.${Device}.user_name}
	# ${DEVICES.${Device}.user_name}
	
	${ssh_result}=		cli ssh		DUT_LAN_SSH    cat /tmp/.mesh_topo_info		60		root@WNRFQQ-112BE
	#Log To Console		${ssh_result}
	RETURN		${ssh_result}
