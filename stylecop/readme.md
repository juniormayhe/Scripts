# Using Code analyzers in netcore projects.

You can use NetCore, Sonarqube, StyleCop, etc.

## Add a ruleset file into csproj

A project.ruleset file sample:

```
﻿<?xml version="1.0" encoding="utf-8"?>
<RuleSet Name="Rules for StyleCop.Analyzers" Description="Code analysis rules for Inventory Read Model." ToolsVersion="15.0">
  <Rules AnalyzerId="DocumentationAnalyzers" RuleNamespace="DocumentationAnalyzers">
    <Rule Id="DOC100" Action="Warning" />
    <Rule Id="DOC101" Action="Warning" />
    <Rule Id="DOC102" Action="Warning" />
    <Rule Id="DOC103" Action="Warning" />
    <Rule Id="DOC104" Action="Warning" />
    <Rule Id="DOC105" Action="Warning" />
    <Rule Id="DOC106" Action="Warning" />
    <Rule Id="DOC107" Action="Warning" />
    <Rule Id="DOC108" Action="Warning" />
    <Rule Id="DOC200" Action="Warning" />
    <Rule Id="DOC201" Action="Warning" />
    <Rule Id="DOC202" Action="Warning" />
    <Rule Id="DOC203" Action="Warning" />
    <Rule Id="DOC204" Action="Warning" />
  </Rules>
  <Rules AnalyzerId="Microsoft.Analyzers.ManagedCodeAnalysis" RuleNamespace="Microsoft.Rules.Managed">
    <Rule Id="CA1001" Action="Warning" />
    <Rule Id="CA1009" Action="Warning" />
    <Rule Id="CA1016" Action="Warning" />
    <Rule Id="CA1033" Action="Warning" />
    <Rule Id="CA1049" Action="Warning" />
    <Rule Id="CA1060" Action="Warning" />
    <Rule Id="CA1061" Action="Warning" />
    <Rule Id="CA1063" Action="Warning" />
    <Rule Id="CA1065" Action="Warning" />
    <Rule Id="CA1301" Action="Warning" />
    <Rule Id="CA1400" Action="Warning" />
    <Rule Id="CA1401" Action="Warning" />
    <Rule Id="CA1403" Action="Warning" />
    <Rule Id="CA1404" Action="Warning" />
    <Rule Id="CA1405" Action="Warning" />
    <Rule Id="CA1410" Action="Warning" />
    <Rule Id="CA1415" Action="Warning" />
    <Rule Id="CA1821" Action="Warning" />
    <Rule Id="CA1900" Action="Warning" />
    <Rule Id="CA1901" Action="Warning" />
    <Rule Id="CA2002" Action="Warning" />
    <Rule Id="CA2100" Action="Warning" />
    <Rule Id="CA2101" Action="Warning" />
    <Rule Id="CA2108" Action="Warning" />
    <Rule Id="CA2111" Action="Warning" />
    <Rule Id="CA2112" Action="Warning" />
    <Rule Id="CA2114" Action="Warning" />
    <Rule Id="CA2116" Action="Warning" />
    <Rule Id="CA2117" Action="Warning" />
    <Rule Id="CA2122" Action="Warning" />
    <Rule Id="CA2123" Action="Warning" />
    <Rule Id="CA2124" Action="Warning" />
    <Rule Id="CA2126" Action="Warning" />
    <Rule Id="CA2131" Action="Warning" />
    <Rule Id="CA2132" Action="Warning" />
    <Rule Id="CA2133" Action="Warning" />
    <Rule Id="CA2134" Action="Warning" />
    <Rule Id="CA2137" Action="Warning" />
    <Rule Id="CA2138" Action="Warning" />
    <Rule Id="CA2140" Action="Warning" />
    <Rule Id="CA2141" Action="Warning" />
    <Rule Id="CA2146" Action="Warning" />
    <Rule Id="CA2147" Action="Warning" />
    <Rule Id="CA2149" Action="Warning" />
    <Rule Id="CA2200" Action="Warning" />
    <Rule Id="CA2202" Action="Warning" />
    <Rule Id="CA2207" Action="Warning" />
    <Rule Id="CA2212" Action="Warning" />
    <Rule Id="CA2213" Action="Warning" />
    <Rule Id="CA2214" Action="Warning" />
    <Rule Id="CA2216" Action="Warning" />
    <Rule Id="CA2220" Action="Warning" />
    <Rule Id="CA2229" Action="Warning" />
    <Rule Id="CA2231" Action="Warning" />
    <Rule Id="CA2232" Action="Warning" />
    <Rule Id="CA2235" Action="Warning" />
    <Rule Id="CA2236" Action="Warning" />
    <Rule Id="CA2237" Action="Warning" />
    <Rule Id="CA2238" Action="Warning" />
    <Rule Id="CA2240" Action="Warning" />
    <Rule Id="CA2241" Action="Warning" />
    <Rule Id="CA2242" Action="Warning" />
  </Rules>
  <Rules AnalyzerId="Microsoft.CodeAnalysis.CSharp.Analyzers" RuleNamespace="Microsoft.CodeAnalysis.CSharp.Analyzers">
    <Rule Id="RS1022" Action="None" />
  </Rules>
  <Rules AnalyzerId="Microsoft.CodeAnalysis.CSharp.Features" RuleNamespace="Microsoft.CodeAnalysis.CSharp.Features">
    <Rule Id="IDE0005" Action="Warning" />
  </Rules>
  <Rules AnalyzerId="SonarAnalyzer.CSharp" RuleNamespace="SonarAnalyzer.CSharp">
    <Rule Id="S100" Action="Warning" />
    <Rule Id="S103" Action="Warning" />
    <Rule Id="S105" Action="Warning" />
    <Rule Id="S1109" Action="Warning" />
    <Rule Id="S113" Action="Warning" />
    <Rule Id="S121" Action="Warning" />
    <Rule Id="S122" Action="Warning" />
    <Rule Id="S1226" Action="Warning" />
    <Rule Id="S127" Action="Warning" />
    <Rule Id="S131" Action="Warning" />
    <Rule Id="S1075" Action="None" />
    <Rule Id="S1659" Action="Warning" />
    <Rule Id="S1858" Action="Warning" />
    <Rule Id="S1994" Action="Warning" />
    <Rule Id="S2070" Action="Warning" />
    <Rule Id="S2156" Action="Warning" />
    <Rule Id="S2228" Action="Warning" />
    <Rule Id="S2302" Action="Warning" />
    <Rule Id="S2357" Action="Warning" />
    <Rule Id="S2387" Action="Warning" />
    <Rule Id="S2674" Action="Warning" />
    <Rule Id="S2699" Action="Warning" />
    <Rule Id="S2701" Action="Warning" />
    <Rule Id="S2760" Action="Warning" />
    <Rule Id="S2952" Action="Warning" />
    <Rule Id="S2955" Action="Warning" />
    <Rule Id="S3215" Action="Warning" />
    <Rule Id="S3216" Action="Warning" />
    <Rule Id="S3240" Action="Warning" />
    <Rule Id="S3431" Action="Warning" />
    <Rule Id="S4457" Action="None" />
  </Rules>
  <Rules AnalyzerId="StyleCop.Analyzers" RuleNamespace="StyleCop.Analyzers">
    <Rule Id="SA0001" Action="None" />
    <Rule Id="SA1412" Action="Warning" />
    <Rule Id="SA1413" Action="None" />
    <Rule Id="SA1600" Action="None" />
    <Rule Id="SA1601" Action="None" />
    <Rule Id="SA1602" Action="None" />
    <Rule Id="SA1609" Action="Warning" />
    <Rule Id="SA1633" Action="None" />
    <Rule Id="SA1629" Action="None" />	
  </Rules>
</RuleSet>
```
Another sample at https://carlos.mendible.com/2017/08/24/net-core-code-analysis-and-stylecop/

## Code Analysis reference in csproj

you can have differente rulesets for different build configurations Debug and Release:

```
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>netcoreapp2.2</TargetFramework>
    <RuntimeIdentifiers>linux-x64;win10-x64</RuntimeIdentifiers>
  </PropertyGroup>

  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|AnyCPU'">
    <NoWarn>1701;1702;CS1591</NoWarn>
    <CodeAnalysisRuleSet>stylecop.ruleset</CodeAnalysisRuleSet>
  </PropertyGroup>

  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|AnyCPU'">
    <NoWarn>1701;1702;CS1591</NoWarn>
    <CodeAnalysisRuleSet>stylecop.release.ruleset</CodeAnalysisRuleSet>
  </PropertyGroup>
  ...
```
