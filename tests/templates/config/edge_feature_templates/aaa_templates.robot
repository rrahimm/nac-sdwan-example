*** Settings ***
Documentation   Verify Switchport Feature template
Suite Setup     Login SDWAN Manager
Suite Teardown    Run On Last Process    Logout SDWAN Manager
Default Tags    sdwan    config    feature_templates
Resource        ../../sdwan_common.resource

{% if sdwan.edge_feature_templates.aaa_templates is defined %}

*** Test Cases ***
Get AAA Feature Template
    ${r}=    Get On Session    sdwan_manager    /dataservice/template/feature
    ${r}=    Get Value From Json    ${r.json()}    $..data[?(@..templateType=="cedge_aaa")]
    Set Suite Variable    ${r}

{% for aaa_template in sdwan.edge_feature_templates.aaa_templates | default([]) %}

Verify Edge Feature Template AAA Feature Template {{ aaa_template.name }}
    ${template_id}=    Get Value From Json    ${r}    $[?(@.templateName=="{{ aaa_template.name }}")]
    Should Be Equal Value Json String    ${template_id}    $..templateName    {{ aaa_template.name }}    msg=AAA template name
    Should Be Equal Value Json String    ${template_id}    $..templateDescription    {{ aaa_template.description }}    msg=AAA template description

{% set test_list = [] %}
{% for item in aaa_template.device_types | default(defaults.sdwan.edge_feature_templates.aaa_templates.device_types) %}
{% set test = "vedge-" ~ item %}
{% set _ = test_list.append(test) %}
{% endfor %}

    ${dt_list}=    Get Value From Json    ${template_id}    $..deviceType
    ${test_list}=    Create List    {{ test_list | join('   ') }}
    Lists Should Be Equal    ${dt_list[0]}    ${test_list}    ignore_order=True    msg=device type

    ${template_id}=    Get Value From Json    ${r}    $[?(@.templateName=="{{ aaa_template.name }}")].templateId
    ${r_id}=    GET On Session    sdwan_manager    /dataservice/template/feature/definition/${template_id[0]}

    Should Be Equal Value Json List Length    ${r_id.json()}    $..["accounting-rule"].vipValue    {{ aaa_template.accounting_rules | length }}    msg=accounting rules

{% for accounting_index in range(aaa_template.accounting_rules | default([]) | length()) %}

    Should Be Equal Value Json String    ${r_id.json()}    $..["accounting-rule"].vipValue[{{accounting_index}}].method.vipValue    {{ aaa_template.accounting_rules[accounting_index].method | default("not_defined")}}    msg=method
    Should Be Equal Value Json String    ${r_id.json()}    $..["accounting-rule"].vipValue[{{accounting_index}}].level.vipValue     {{ aaa_template.accounting_rules[accounting_index].privilege_level | default("not_defined")}}    msg=privilege level
    Should Be Equal Value Json String    ${r_id.json()}    $..["accounting-rule"].vipValue[{{accounting_index}}].["start-stop"].vipValue    {{ aaa_template.accounting_rules[accounting_index].start_stop | default("not_defined") | lower }}    msg=start_stop
    Should Be Equal Value Json String    ${r_id.json()}    $..["accounting-rule"].vipValue[{{accounting_index}}].["start-stop"].vipVariableName    {{ aaa_template.accounting_rules[accounting_index].start_stop_variable | default("not_defined")}}    msg=start_stop variable

{% if aaa_template.accounting_rules[accounting_index].groups | default("not_defined") == 'not_defined' %}
    Should Be Equal Value Json String    ${r_id.json()}    $..["accounting-rule"].vipValue[{{accounting_index}}].group.vipValue    {{ aaa_template.accounting_rules[accounting_index].groups | default("not_defined") }}    msg=no rules defined
{% else %}
    ${grp_list}=    Create List    {{ aaa_template.accounting_rules[accounting_index].groups | join('   ') }}
    ${group}=    Get Value From Json    ${r_id.json()}    $..["accounting-rule"].vipValue[{{accounting_index}}].group.vipValue
    ${rec_group}=    Split String    ${group[0]}
    Lists Should Be Equal    ${rec_group}    ${grp_list}    ignore_order=True    msg=groups
{% endif %}

{% endfor %}

{% if aaa_template.authentication_and_authorization_order | default("not_defined") == 'not_defined' %}
    Should Be Equal Value Json String    ${r_id.json()}    $..["server-auth-order"].vipValue    {{ aaa_template.authentication_and_authorization_order | default("not_defined") }}    msg=no authentication defined
{% else %}
    ${auth_list}=    Create List    {{ aaa_template.authentication_and_authorization_order | join('   ') }}
    ${auth}=    Get Value From Json    ${r_id.json()}    $..["server-auth-order"].vipValue
    ${rec_auth}=    Split String    ${auth[0]}    ,
    Lists Should Be Equal    ${rec_auth}    ${auth_list}    ignore_order=True    msg=authentication and authorization order
{% endif %}

    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-config-commands"].vipValue    {{ aaa_template.authorization_config_commands | lower | default("not_defined") }}    msg=authorization config commands value
    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-config-commands"].vipVariableName    {{ aaa_template.authorization_config_commands_variable | default("not_defined") }}    msg=authorization config commands variable

    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-console"].vipValue    {{ aaa_template.authorization_console | lower | default("not_defined") }}    msg=authorization console value
    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-console"].vipVariableName    {{ aaa_template.authorization_console_variable | default("not_defined") }}    msg=authorization console variable

    Should Be Equal Value Json List Length    ${r_id.json()}    $..["authorization-rule"].vipValue    {{ aaa_template.authorization_rules | length }}    msg=authorization rules
    
{% for authorization_index in range(aaa_template.authorization_rules | default([]) | length()) %}
    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-rule"].vipValue[{{authorization_index}}].method.vipValue    {{ aaa_template.authorization_rules[authorization_index].method | default("not_defined") }}    msg=method
    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-rule"].vipValue[{{authorization_index}}].level.vipValue    {{ aaa_template.authorization_rules[authorization_index].privilege_level | default("not_defined") }}    msg=privilege level
    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-rule"].vipValue[{{authorization_index}}].["if-authenticated"].vipValue    {{ aaa_template.authorization_rules[authorization_index].authenticated | lower | default("not_defined")}}    msg=authenticated

{% if aaa_template.authorization_rules[authorization_index].groups | default("not_defined") == 'not_defined' %}
    Should Be Equal Value Json String    ${r_id.json()}    $..["authorization-rule"].vipValue[{{authorization_index}}].group.vipValue    {{ aaa_template.authorization_rules[authorization_index].groups | default("not_defined") }}    msg=no authorization rules groups
{% else %}
    ${group}=    Create List    {{ aaa_template.authorization_rules[authorization_index].groups | join('   ') }}
    ${auth_grp}=    Get Value From Json    ${r_id.json()}    $..["authorization-rule"].vipValue[{{authorization_index}}].group.vipValue
    ${rec_grp}=    Split String    ${auth_grp[0]}    ,
    Lists Should Be Equal    ${rec_grp}    ${group}    ignore_order=True    msg=authorization rules groups
{% endif %}

{% endfor %}

    Should Be Equal Value Json String    ${r_id.json()}    $..authentication.dot1x.default..vipValue    {{ aaa_template.dot1x_authentication | lower }}    msg=dot1x authentication
    Should Be Equal Value Json String    ${r_id.json()}    $..authentication.dot1x.default..vipVariableName    {{ aaa_template.dot1x_authentication_variable }}    msg=dot1x authentication variable

    Should Be Equal Value Json String    ${r_id.json()}    $..accounting.dot1x.default..vipValue    {{ aaa_template.dot1x_accounting | lower }}    msg=dot1x accounting
    Should Be Equal Value Json String    ${r_id.json()}    $..accounting.dot1x.default..vipVariableName    {{ aaa_template.dot1x_accounting_variable }}    msg=dot1x accounting variable

    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["domain-stripping"].vipValue    {{ aaa_template.radius_dynamic_author.domain_stripping }}    msg=domain stripping
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["domain-stripping"].vipVariableName    {{ aaa_template.radius_dynamic_author.domain_stripping_variable }}    msg=domain stripping variable
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["auth-type"].vipValue    {{ aaa_template.radius_dynamic_author.authentication_type }}    msg=authentication type
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["auth-type"].vipVariableName    {{ aaa_template.radius_dynamic_author.authentication_type_variable }}    msg=authentication type variable
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"].port.vipValue    {{ aaa_template.radius_dynamic_author.port }}    msg=port
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"].port.vipVariableName    {{ aaa_template.radius_dynamic_author.port_variable }}    msg=port variable
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["rda-server-key"].vipValue    {{ aaa_template.radius_dynamic_author.server_key }}    msg=server key
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["rda-server-key"].vipVariableName    {{ aaa_template.radius_dynamic_author.server_key_variable }}    msg=server key variable

    Should Be Equal Value Json List Length    ${r_id.json()}    $..["radius-dynamic-author"]["radius-client"].vipValue    {{ aaa_template.radius_dynamic_author.clients | length }}    msg=clients

{% for radius_dac in range(aaa_template.radius_dynamic_author.clients | default([]) | length()) %}
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["radius-client"].vipValue[{{radius_dac}}].ip.vipValue    {{ aaa_template.radius_dynamic_author.clients[radius_dac].ip | default("not_defined") }}    msg=ip
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["radius-client"].vipValue[{{radius_dac}}].ip.vipVariableName    {{ aaa_template.radius_dynamic_author.clients[radius_dac].ip_variable | default("not_defined") }}    msg=ip variable
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["radius-client"].vipValue[{{radius_dac}}].vpn.vipValue..name.vipValue    {{ aaa_template.radius_dynamic_author.clients[radius_dac].vpn_id | default("not_defined") }}    msg=vpn id
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["radius-client"].vipValue[{{radius_dac}}].vpn.vipValue..name.vipVariableName    {{ aaa_template.radius_dynamic_author.clients[radius_dac].vpn_id_variable | default("not_defined") }}    msg=vpn id variable
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-dynamic-author"]["radius-client"].vipValue[{{radius_dac}}].vpn.vipValue..server-key.vipValue    {{ aaa_template.radius_dynamic_author.clients[radius_dac].server_key | default("not_defined") }}    msg=server key
{% endfor %}

    Should Be Equal Value Json List Length    ${r_id.json()}    $..radius.vipValue    {{ aaa_template.radius_server_groups | length }}    msg=radius server group

{% for radius_index in range(aaa_template.radius_server_groups | default([]) | length()) %}

    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}]["group-name"].vipValue    {{ aaa_template.radius_server_groups[radius_index].name | default("not_defined") }}    msg=name
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}]["source-interface"].vipValue    {{ aaa_template.radius_server_groups[radius_index].source_interface }}    msg=source interface
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}]["source-interface"].vipVariableName    {{ aaa_template.radius_server_groups[radius_index].source_interface_variable }}    msg=source interface variable
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].vpn.vipValue    {{ aaa_template.radius_server_groups[radius_index].vpn_id }}    msg=vpn id

    Should Be Equal Value Json List Length    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue    {{ aaa_template.radius_server_groups[radius_index].servers | length }}    msg=servers

{% for item in range(aaa_template.radius_server_groups[radius_index].servers | default([]) | length()) %}
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}].address.vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].address | default("not_defined") }}    msg=address
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}]["auth-port"].vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].authentication_port | default("not_defined") }}    msg=authentication port
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}]["auth-port"].vipVariableName    {{ aaa_template.radius_server_groups[radius_index].servers[item].authentication_port_variable | default("not_defined") }}    msg=authentication port variable

    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}]["acct-port"].vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].accounting_port }}    msg=accounting port
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}]["acct-port"].vipVariableName    {{ aaa_template.radius_server_groups[radius_index].servers[item].accounting_port_variable }}    msg=accounting port variable

    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}].timeout.vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].timeout }}    msg=timeout
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}].timeout.vipVariableName    {{ aaa_template.radius_server_groups[radius_index].servers[item].timeout_variable }}    msg=timeout variable

    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}].retransmit.vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].retransmit_count }}    msg=retransmit count
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}].retransmit.vipVariableName    {{ item.retransmit_count_variable }}    msg=retransmit count variable

    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}]["key-type"].vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].key_type }}    msg=key type
    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}]["key-type"].vipVariableName    {{ aaa_template.radius_server_groups[radius_index].servers[item].key_type_variable }}    msg=key type variable

    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}].key.vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].key }}    msg=key

    Should Be Equal Value Json String    ${r_id.json()}    $..radius.vipValue[{{ radius_index }}].server.vipValue[{{ item }}]["secret-key"].vipValue    {{ aaa_template.radius_server_groups[radius_index].servers[item].secret_key }}    msg=secret key

    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-trustsec"]["cts-auth-list"].vipValue    {{ aaa_template.radius_trustsec.cts_authorization_list }}    msg=cts authorization list
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-trustsec"]["cts-auth-list"].vipVariableName    {{ aaa_template.radius_trustsec.cts_authorization_list_variable }}    msg=cts authorization list variable
    Should Be Equal Value Json String    ${r_id.json()}    $..["radius-trustsec"]["radius-trustsec-group"].vipValue    {{ aaa_template.radius_trustsec.server_group }}    msg=server group

{% endfor %}

{% endfor %}

   Should Be Equal Value Json List Length    ${r_id.json()}   $..tacacs..vipValue    {{ aaa_template.tacacs_server_groups | length }}    msg=tacacs server group

{% for aaa_index in range(aaa_template.tacacs_server_groups | default([]) | length()) %}

    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}]["group-name"].vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].name | default("not_defined") }}    msg=name
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}]..vpn.vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].vpn_id }}    msg=vpn id
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}]["source-interface"].vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].source_interface | default("not_defined") }}    msg=source_interface
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}]["source-interface"].vipVariableName    {{ aaa_template.tacacs_server_groups[aaa_index].source_interface_variable | default("not_defined") }}    msg=source interface variable

    Should Be Equal Value Json List Length    ${r_id.json()}   $..tacacs.vipValue[{{ aaa_index }}]..server.vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].servers | length }}    msg=servers

{% for item in range(aaa_template.tacacs_server_groups[aaa_index].servers | default([]) | length()) %}

    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}].server.vipValue[{{ item }}].address.vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].servers[item].address | default("not_defined") }}    msg=address
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}].server.vipValue[{{ item }}].port.vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].servers[item].port | default("not_defined") }}    msg=port
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}].server.vipValue[{{ item }}].port.vipVariableName    {{ aaa_template.tacacs_server_groups[aaa_index].servers[item].port_variable | default("not_defined") }}    msg=port variable
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}].server.vipValue[{{ item }}].timeout.vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].servers[item].timeout | default("not_defined") }}    msg=timeout
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}].server.vipValue[{{ item }}].timeout.vipVariableName    {{ aaa_template.tacacs_server_groups[aaa_index].servers[item].timeout_variable | default("not_defined") }}    msg=timeout variable
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}].server.vipValue[{{ item }}].key.vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].servers[item].key | default("not_defined")}}    msg=key
    Should Be Equal Value Json String    ${r_id.json()}    $..tacacs.vipValue[{{ aaa_index }}].server.vipValue[{{ item }}]["secret-key"].vipValue    {{ aaa_template.tacacs_server_groups[aaa_index].servers[item].secret_key | default("not_defined") }}    msg=secret_key

{% endfor %}

{% endfor %}

    Should Be Equal Value Json List Length    ${r_id.json()}   $..user.vipValue    {{ aaa_template.users | length }}    msg=users

{% for names in aaa_template.users | default([])  %}

    Should Be Equal Value Json String    ${r_id.json()}    $..user.vipValue[{{loop.index0}}].name.vipValue    {{ names.name | default("not_defined")}}    msg=name
    Should Be Equal Value Json String    ${r_id.json()}    $..user.vipValue[{{loop.index0}}].vipOptional    {{ names.optional | default("not_defined")}}    msg=optional
    Should Be Equal Value Json String    ${r_id.json()}    $..user.vipValue[{{loop.index0}}].password.vipValue    {{ names.password | default("not_defined")}}    msg=password
    Should Be Equal Value Json String    ${r_id.json()}    $..user.vipValue[{{loop.index0}}].privilege.vipValue    {{ names.privilege_level | default("not_defined")}}    msg=privilege level
    Should Be Equal Value Json String    ${r_id.json()}    $..user.vipValue[{{loop.index0}}].privilege.vipVariableName    {{ names.privilege_level_variable | default("not_defined")}}    msg=privilege level variable
    Should Be Equal Value Json String    ${r_id.json()}    $..user.vipValue[{{loop.index0}}].secret.vipValue    {{ names.secret | default("not_defined")}}    msg=secret

{% if names.ssh_rsa_keys | default("not_defined") == 'not_defined' %}
    Should Be Equal Value Json String    ${r_id.json()}    $..user.vipValue[{{loop.index0}}]["pubkey-chain"].vipValue..["key-string"].vipValue    {{ names.ssh_rsa_keys | default("not_defined") }}    msg=no ssh rsa key
{% else %}
    ${ssh_key}=    Create List    {{ names.ssh_rsa_keys | join('   ') }}
    ${rsa_key}=    Get Value From Json    ${r_id.json()}    $..user.vipValue[{{loop.index0}}]["pubkey-chain"].vipValue..["key-string"].vipValue
    ${rec_key}=    Split String    ${rsa_key[0]}    ,
    Lists Should Be Equal    ${rec_key}    ${ssh_key}    ignore_order=True    msg=ssh rsa key

{% endif %}

{% endfor %}

{% endfor %}

{% endif %}