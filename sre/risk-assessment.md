# Risk assessment example

> This is an example of a business risk assessment deemed to be a model for teams from assessed areas by the SRE engineering team. 
> It can be adjusted to fit particular cases.

|Category|Risk|Probability|Severity|Mitigation|Responsible|Risk level|
|--|--|--|--|--|--|--|
||||||||


## Category

Feel free to group relevant risks by category, subject, or topic. This is useful to ease reading by others by better organizing your risk assessment document.

Some category ideas:

- Application performance
- Partner experience: Storm app
- Internal experience: Sales app: security and permissions
- Internal services: logging
- External services / partners
- Internal process: monitoring
- Internal process: buy-flow…

## Risk
Describe relevant loss or operational degradation to business when it comes to promoting changes on applications hosted in the live environment. 

The risks enumerated here may refer to any scope of change, such as: configuration/toggle changes, code refactoring/improvements, hotfixes, the addition of features, or initiative rollouts.

Some risk statement ideas:

- Application isn’t scaling  up when needed as the number of client requests increases
- Unable to print AWB for shipping
- Customer orders not being consolidated…
- Orders not being allocated to expected merchants
- Application outage or permanent downtime…

## Probability
Probability refers to the likelihood or possibility of a risk potential occurring, and it’s measured in qualitative values such as low, medium, or high. 

Choose one of the following

- Frequent: probably will occur very often
- Likely: probably will occur often
- Occasional: expected to occur some times
- Rare: expected to occur on a rare basis
- Unlikely: Unexpected but might occur

## Severity
When the risk happens, how severe is the damage to business? 

The severity can be understood also as an overall impact on business.

Choose one of the following

- Catastrophic: complete business operations interruption
- Critical: probably will occur often
- Moderate: damage hinders or slows down business operations
- Negligible: damage does not prevent or affect main business operations

## Mitigation

Specify a link or actions to be taken to mitigate the risk in order to recover from damage or reduce the damage to business operations

Some mitigation ideas:

- Communicate to Engineer Manager the ETA for fixes, aligned with stakeholders expectations
- Show partners how to circumvent AWB printing issues 
- Redeploy previous version of app 
- Open ticket to Azure BLOB Storage support to fix SFTP user credentials
- Update brand and merchant ranking configurations to allocate orders on alternative locations

## Responsible

Which person or team is responsible for mitigating the risk.

<person or team>

## Risk level
  
This optional and is based on Risk level matrix presented below. The risk level helps you evaluate the risk level, so you can plan mitigations and prioritize work on business reliability if a risk becomes real.
  
Find the risk level that matches Severity and Probability, already coded in our Risk level matrix. The possible outcomes are:

- Extremely high
- High
- Medium
- Low

## Risk matrix
  
  > If desired you add a column to your Risk assessment table to classify Risk level as Extremely High, High, Medium, or Low by checking the relationship between Severity (how much damage would be caused) and Probability (how often it would happen).

![](https://github.com/juniormayhe/Scripts/blob/master/sre/2021-06-17_10h29_24.png?raw=true)
