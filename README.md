AQUARYTHU
Complete Product Requirement Document (PRD)
Technical & Product Architecture Specification
1️⃣ PRODUCT VISION
Mission

Help shrimp farmers achieve better FCR through disciplined feeding and water-based best practices.

Core Philosophy

AquaRythu does not:

Guarantee profit

Sell feed

Recommend brands

Replace farmer judgment

AquaRythu enforces:

Feeding discipline

Tray-based execution

Water quality tracking

Behavior-based intelligence

2️⃣ END GOAL
Primary Outcome

Improve FCR by enforcing structured best practices.

𝐹
𝐶
𝑅
=
𝑇
𝑜
𝑡
𝑎
𝑙
𝐹
𝑒
𝑒
𝑑
𝑈
𝑠
𝑒
𝑑
/
𝑇
𝑜
𝑡
𝑎
𝑙
𝐵
𝑖
𝑜
𝑚
𝑎
𝑠
𝑠
𝐻
𝑎
𝑟
𝑣
𝑒
𝑠
𝑡
𝑒
𝑑
FCR=TotalFeedUsed/TotalBiomassHarvested

Feed = 55–65% of shrimp farming cost.

Small FCR improvement (0.1–0.2) = major margin gain.

3️⃣ TARGET USERS

Primary:

Vannamei shrimp farmers (India)

1–10 acre farms

Tray feeding workflow

Secondary:

Supervisors

Farm workers

4️⃣ PRICING MODEL (LOCKED)
FREE PLAN

Unlimited feed logging

Unlimited ponds

Blind feeding auto schedule

Tray logging (per tray mandatory)

Feed mix instructions

Water test logging

History storage

Offline capability

PRO PLAN (~₹499/month)

Feed increase/decrease suggestions

Overfeeding alerts

Underfeeding alerts

Missed feed alerts

Feed discipline score

FCR calculation

Efficiency score

Appetite trend graph

Pond comparison

Water-based feeding intelligence

Survival estimation

Harvest readiness indicator

Reports

No per-pond pricing.
No outcome-based monetization.

5️⃣ CORE WORKFLOW OVERVIEW

Pond Creation
↓
Blind Feeding Phase (DOC 0–30)
↓
Automatic Transition to Tray Mode
↓
Structured Tray Logging
↓
Weekly Water Logging
↓
Intelligence Engine (PRO)
↓
FCR Optimization

6️⃣ MODULE LEVEL PRD
MODULE 1: AUTHENTICATION
Functional Requirements

Email + Password login

Role selection:

Farmer

Supervisor

Worker

Multi-pond access

Session persistence

Non-functional

JWT-based auth

Secure password hashing

Role-based access enforcement

MODULE 2: FARM & POND SETUP
Pond Creation Fields

Pond name

Acre size

Stocking count

PL per m²

Stocking date

Number of trays

Aeration HP

Water source

On Save

System auto-generates:

Blind feeding schedule (DOC 1–30)

Based on:

Stocking count

Acre size

Standard feed table

Editable by supervisor.

MODULE 3: BLIND FEEDING ENGINE

Active when:

DOC < 30

Flow

System suggests feed

Supervisor edits & sets final quantity

Worker executes

Round marked complete

Stored Data

Feed quantity

Feed type

Mix instructions

Timestamp

User ID

MODULE 4: TRAY MODE TRANSITION

Condition:

DOC >= 30 → feeding_mode = tray

Manual override allowed.

MODULE 5: TRAY LOGGING ENGINE

Critical core module.

Trigger

After each feed round (~2 hours later)

For each tray (mandatory):

Options:

Completed

Little Left

Half

Too Much

No skipping.
All trays required.

Tray Score Calculation

Weights:

Completed = 1.0
Little Left = 0.75
Half = 0.5
Too Much = 0.25

Score = Average(weight)

Stored per feed round.

FREE users:
Can log trays.

PRO users:
Get suggestions based on score.

MODULE 6: FEED MIX INSTRUCTION ENGINE

Supervisor can define:

Binder

Additives

Growth promoter

Gel

Custom text

Worker sees exact mix instructions.

Execution only.
No brand recommendation.

MODULE 7: WATER TESTING MODULE

Weekly mandatory reminder.

Parameters

Salinity

DO

pH

Temperature

Ammonia

Alkalinity

Stored per pond.

FREE:
Logging only.

PRO:
Water-based feed intelligence.

MODULE 8: INTELLIGENCE ENGINE (PRO)

Combines:

Tray Score

Water Quality

Trend Stability

Missed Feeding

Historical Feed Pattern

Decision Framework Example

If:

Tray score > 0.85
AND water stable
→ Suggest slight increase (3–5%)

If:

Tray score < 0.6
OR ammonia high
→ Suggest reduce

If:

Salinity swing > 3 ppt
→ Conservative feed suggestion

MODULE 9: FCR ENGINE (PRO)

Inputs:

Total feed used

Harvest weight

Survival estimate

Outputs:

Current FCR

Trend FCR

Efficiency score

MODULE 10: DASHBOARD

FREE:

Today feed plan

Pending tray checks

Feed history

Water log history

PRO:

Feed suggestions

FCR widget

Alerts

Stability score

Appetite trend

7️⃣ TECHNICAL ARCHITECTURE
Frontend

Flutter

Architecture:

Feature-based folder structure

Riverpod or Bloc for state management

Offline-first storage (Hive or SQLite)

Sync engine

Backend

Supabase (Postgres + Auth + Storage)

Tables:

users

farms

ponds

pond_config

blind_feed_schedule

feed_rounds

tray_logs

feed_mix_instructions

water_tests

subscriptions

alerts

Sync Logic

Offline mode:

Local write

sync_pending flag

Background retry

Conflict rule:

Last write wins (for logging only)

8️⃣ NON-FUNCTIONAL REQUIREMENTS

App must work in low-network villages

Fast UI (max 2-second response)

Minimal data entry friction

Large buttons for field workers

Multi-language support (future)

9️⃣ DATA INTELLIGENCE ROADMAP (PHASE 2+)

Appetite stability score

Early disease pattern detection

Predictive FCR

Cross-farm benchmarking (anonymous)

Partial harvest intelligence

🔟 SECURITY

Role-based access control

Data isolation per farm

Secure subscription validation

No cross-pond data leaks

11️⃣ RISK ANALYSIS

Risk: Farmers ignore tray updates
Mitigation: Make tray update mandatory to close round

Risk: Wrong water data
Mitigation: Range validation

Risk: Over-reliance on suggestions
Mitigation: Always show "Final decision is farmer's responsibility"

12️⃣ CORE DIFFERENTIATION

Most apps:

Sell inputs

Track expenses

Provide IoT hardware

AquaRythu:

Enforces feeding discipline
Uses tray-based execution
Combines water + appetite signals
Targets FCR improvement

13️⃣ PRODUCT STATEMENT

AquaRythu is a Feed & Water Discipline Intelligence System designed to improve shrimp farm FCR by enforcing best practices through structured tray execution and water-aware decision support.