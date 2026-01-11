# Fog-Cloud Diabetes Monitoring System

## Overview
This repository contains the source code and dataset for the paper titled **"A Hybrid Fog-Cloud Computing Framework for Real-Time Critical Healthcare Monitoring"**. The system utilizes smartphones as Fog Nodes to optimize latency in IoMT environments.

## Dataset
The dataset utilized in this study (`Fog_System_Evaluation_Dataset.csv`) contains simulated physiological readings for 50 patients, demonstrating the system's efficiency in bandwidth reduction and latency optimization.

## System Components
1. **Fog Node (Android App):** Handles local processing and decision making.
2. **Cloud Server:** Handles long-term storage and visualization.

## Algorithm
The core logic implements an adaptive 4-state classification algorithm (Critical, Acute, Pre-Alert, Stable).