## Enhanced Disaster Recovery Robot

The Enhanced Disaster Recovery Robot is a sophisticated robotic simulation designed to assist in disaster recovery operations, specifically in earthquake-stricken areas. Using CoppeliaSim, the robot is programmed to navigate through complex environments, avoid obstacles, and locate survivors, providing an innovative approach to disaster response.

{TODO Image  Placeholder for Project Overview}

## Table of Contents
- [Technologies](#technologies)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Technologies
- CoppeliaSim Edu
- Lua

## Features
- **Obstacle Avoidance:** Navigates around debris (`DebrisToDetect`) and compromised infrastructure (`InfraToDetect`).
- **Survivor Detection:** Identifies and provides assistance to survivors (`Bill` object) using the `peopleSensor`.
- **Adaptive Navigation:** Responds to real-time changes in the environment to optimize navigation and assistance efforts.

## Installation
1. Install CoppeliaSim Edu from the [official website](https://www.coppeliarobotics.com/downloads).
2. Obtain the project files by cloning or downloading this repository.

## Usage
1. Open the `disaster-relief-bot.ttt` simulation file in CoppeliaSim.
2. Ensure the Lua script is correctly associated with the robot.
3. Initiate the simulation to observe the robot's functionality in a simulated disaster recovery scenario.

## License
[MIT License](LICENSE)
