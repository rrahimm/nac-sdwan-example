We would like to make an update to the Centralized Policy Application Aware Routing to take seprate action for few Google Apps.

Task 3 - Create new sequence in the existing application aware routing policy

In this task, you will insert a sequence within the application-aware routing policy `AAR-Policy-01`. Your goal is to create a new entry under this application_aware_routing that specifies how traffic for a particular application should be routed based on SLA requirements.

Use the details below:

Insert this policy as id number 5 (insert between id 4 and id 5) and rename the existing id number 5 to 6 ( for Default)
Details:
rename id=5 to id=6
id=5, name=GOOGLE-APPS, ip_type=ipv4, and type=app_route
match_criterias with an application_list `Google_Apps_New`
actions including a counter_name=AAR-Default, log flag, and a sla_class_list with sla_class_list name=SLA-GOOGLE
preferred_colors=biz-internet
when_sla_not_met action=fallback_to_best_path