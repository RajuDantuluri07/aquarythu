# aquarythu

A new Flutter project.

## Getting Started

🌊 Core of AquaRythu

The core of AquaRythu is very simple but very powerful:

Make shrimp farmers save feed through strict feeding discipline + intelligent decision support.

Everything else is secondary.

🎯 1️⃣ Core Mission

AquaRythu is NOT:

❌ A marketplace

❌ A feed-selling app

❌ A medicine advisory app

❌ A complicated ERP

It IS:

✅ A Feed Discipline + Feed Intelligence System for shrimp farmers.

🧠 2️⃣ Core Philosophy (Locked)

You already decided this clearly:

💰 Monetization must come from feed-saving intelligence.
📝 Feed logging is FREE forever.
🧠 Intelligence layer = paid.

So the real product is not logging.
The real product is decision intelligence.

🐟 3️⃣ What Is the Real Problem in Shrimp Farming?

The biggest cost in shrimp farming:

⚠️ Feed = 55–65% of total farming cost

And the biggest mistake farmers make:

Overfeeding

Blind feeding too long

Ignoring tray signals

Not tracking discipline

No FCR awareness until harvest

So AquaRythu solves:

“How much feed should I give today?”

That one question.

⚙️ 4️⃣ Operational Core Workflow
Step 1: Blind Feeding Phase (0–25/30 DOC)

Auto-generated schedule

Based on stocking count

Editable by farmer

Workers follow set quantity

Step 2: Tray-Based Feeding

Farmer sees:

Pond status

Suggested feed

Feed trend

Over/under warning

Farmer sets final quantity

Worker executes exactly

👆 This execution control is core.

📊 5️⃣ Core Value Engine

AquaRythu runs on 3 internal engines:

🔹 A. Feed Discipline Engine (Basic Plan)

Increase/decrease suggestion

Ideal feed range

Overfeeding detection

Missed feed alerts

Discipline score

🔹 B. Efficiency Engine (Pro Plan)

FCR tracking (post 30 DOC)

Feed efficiency score

Pond comparison

Survival estimation

Abnormal feed alerts

🔹 C. Execution Engine

Worker compliance tracking

Feed mix instruction enforcement

Supervisor visibility

🏗 6️⃣ Structural Core (App Architecture)
Logging Layer (Free Forever)
        ↓
Discipline Intelligence (Basic)
        ↓
Efficiency Optimization (Pro)

This layered model is your moat.

🧱 7️⃣ The True Core in One Sentence

AquaRythu = “Feed Control System for Shrimp Farms”

Not a farm app.
Not a data app.
Not an advisory app.

A Feed Control System.

🚀 8️⃣ Why This Core Is Powerful

Because:

Feed mistakes = invisible loss

Farmers realize loss only at harvest

You make loss visible daily

You control decision before damage happens

That is powerful.

🔐 Final Locked Core Statement

Here is your final core definition:

AquaRythu is a decision-first feed intelligence platform that enforces feeding discipline, optimizes feed efficiency, and reduces invisible feed losses in shrimp farming.

If you want next, I can break this into:

🔥 Investor pitch core

🧠 Technical architecture core

🎯 Landing page core message

💰 Monetization logic core

🛡 Long-term moat strategy core

Tell me which one.

🧠 Technical architecture core
🧠 AquaRythu – Technical Architecture Core

Your app must be simple outside, intelligent inside.

At the heart, AquaRythu is a:

Online-first Feed Logging System + Intelligence Engine layered on top

🏗 1️⃣ High-Level Architecture
Flutter App (Mobile)
        ↓
Repository Layer
        ↓
Supabase (Auth + Postgres + Realtime)
        ↓
Intelligence Engine (Business Logic Layer)

You already decided:

Repository → Supabase → Optional local cache (online-first)

Correct decision for MVP.

📱 2️⃣ Mobile Layer (Flutter)
Responsibilities:

UI Screens

Feeding entry

Pond dashboard

Worker execution view

Supervisor control panel

Plan upgrade screens

Key Principles:

Farmer sets final feed quantity

Worker sees read-only execution

Intelligence only visible if plan allows

🗄 3️⃣ Backend Core – Supabase

Using:

Auth (Login / Signup)

PostgreSQL database

Row Level Security (RLS)

Realtime updates

Core Tables Structure
👤 Users

id

role (farmer / supervisor / worker)

plan_type (free / basic / pro)

🐟 Farms

id

owner_id

🌊 Ponds

id

farm_id

stocking_count

area

DOC

🍽 Feed Logs

pond_id

date

round_number

feed_quantity_set

feed_quantity_actual

tray_status

remarks

📊 Harvest Logs

pond_id

harvest_weight

partial / final

🧠 4️⃣ Intelligence Engine (MOST IMPORTANT)

This is your real product.

It sits between:

Raw Data → Decision Suggestion → Final Feed Set
🔹 A. Blind Feeding Generator (0–30 DOC)

When pond created:

Auto-generate blind feed schedule

Based on stocking_count

Editable

Stored as schedule table

🔹 B. Discipline Engine (Basic Plan)

Runs daily:

Inputs:

DOC

Yesterday feed

Tray signal

Feed trend

Outputs:

Suggested increase/decrease %

Ideal range

Overfeed warning

Discipline score

🔹 C. Efficiency Engine (Pro Plan)

Activated after ~30 DOC or harvest data.

Calculations:

Running FCR

Feed efficiency score

Growth estimation

Abnormal feed spike detection

Pond comparison

🔐 5️⃣ Plan-Based Access Control

Very important architecture rule:

FREE

Only logging

No suggestions

BASIC

Discipline engine visible

PRO

Full efficiency engine

Implementation:

Check plan_type at API/service level

Do NOT calculate heavy analytics for free users

📡 6️⃣ Realtime Execution Control

Feeding Round Flow:

Farmer opens pond

Sees suggestion

Edits final quantity

Saves

Worker device updates instantly

Worker feeds exact quantity

Worker confirms execution

This prevents:

Guess feeding

Worker deviation

Quantity mismatch

💾 7️⃣ Data Strategy
Online-First (Correct for You)

Write directly to Supabase

Local caching only for:

Poor network

Offline feeding entry

No heavy offline sync logic in MVP.

📊 8️⃣ Core Algorithms Layer (Internal)

You don’t need AI initially.

Use:

Rule-based logic

Moving averages

% change thresholds

Trend slope detection

Keep it explainable.

Farmers trust logic they understand.

🛡 9️⃣ Security Core

RLS enabled on all tables

User only sees own farms

Workers restricted to assigned ponds

Supervisor access controlled

⚡ 10️⃣ Scalability Philosophy

Keep backend thin.

All intelligence:

Either in app service layer

Or Supabase edge functions (later)

Do NOT build heavy microservices now.

🧱 Final Technical Core Statement

AquaRythu is an online-first Flutter + Supabase system where feed logging is the base layer, and a rule-based intelligence engine sits on top to enforce discipline and optimize feed efficiency — controlled by plan-based access.