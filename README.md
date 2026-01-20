# Conway's Game of Life

This project is a web-based implementation of **Conway's Game of Life**.

The application allows users to set up and interact with a grid of cells that evolve over time based on the classic rules of the zero-player game devised by John Conway.

## Project Overview

The goal of this project is to demonstrate proficiency in building a modern web application using Ruby on Rails, adhering to clean code practices and the specific requirements provided in the [Extendi Game of Life repository](https://github.com/extendi/game-of-life).

### Game Rules
The classical implementation of the Game of Life is an infinite, two-dimensional orthogonal grid of square cells, each of which is in one of two possible states, live or dead. Every cell interacts with its eight neighbours, which are the cells that are horizontally, vertically, or diagonally adjacent. At each step in time, the following transitions occur:
1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
2. Any live cell with two or three live neighbours lives on to the next generation.
3. Any live cell with more than three live neighbours dies, as if by overpopulation.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

For this variant, the grid is considered to be finite and no life can exist off the edges.

## Key Features

- **User Authentication**: Secure access with e-mail and password.
- **File Upload & Validation**: Upload initial patterns via file input with format validation.
- **Dynamic Matrix**: The grid automatically adjusts its size based on the uploaded input file.
- **Server-Side Evolution**: All generation calculations are performed on the server to ensure logic consistency.
- **Real-time Updates**: The UI reflects the state of the matrix at each iteration using modern Rails techniques (Turbo/Stimulus).
- **Generation Scrubbing**: Navigate through the history of the simulation with the ability to slide through generations both backward and forward.
- **Simulation Control**: A dedicated "Start" button to trigger and visualize the evolution process.

## Tech Stack

- **Ruby**: 4.0.1
- **Framework**: Rails 8.1.2
- **Database**: SQLite3 (using `Solid Cache`, `Solid Queue`, and `Solid Cable` for modern Rails 8 defaults)
- **Frontend**: Hotwire (Turbo & Stimulus) with Importmaps (no Node.js build step required)
- **Deployment**: Kamal (Docker-based)

## Getting Started

### Prerequisites
- Ruby 4.0.1 (managed via `mise` or your preferred version manager)
- SQLite3

### Installation
1. Clone the repository:
   ```bash
   git clone git@github.com:Tretent/game-of-life.git
   cd game_of_life
   ```

2. Run the setup script to install dependencies and prepare the database:
   ```bash
   bin/setup
   ```

3. Start the development server:
   ```bash
   bin/rails server
   ```
   The application will be available at `http://localhost:3000`.

## Usage Guide

Based on the required solution implementation, the application provides the following functionality:

### 1. Grid Interaction
- **Define Grid Size**: Users can specify the dimensions of the grid (number of rows and columns).
- **Manual Toggle**: You can click on individual cells to toggle their state between *alive* and *dead* before starting the simulation.
- **Random Generation**: A "Random" button is available to populate the grid with a random initial state.

### 2. Simulation Control
- **Next Step**: Manually evolve the grid by one generation.
- **Auto-Play/Pause**: Start an automated simulation that evolves at a set interval, or pause it at any time to inspect the current state.
- **Reset**: Clear the grid or return to the initial state.

### 3. State Management
- **Persistence**: The application allows you to save the current state of the grid to the database.
- **Retrieval**: You can view a list of saved games and reload them to continue the simulation or use them as a starting point.

## Testing & Quality

To ensure code quality and functionality, the following tools are used:

- **Tests**: Run the suite using `bin/rails test` (includes system tests with Capybara).
- **Linting**: RuboCop is configured with the Omakase style. Run with `bin/rubocop`.
- **Security**:
    - `bin/brakeman` for static analysis.
    - `bin/bundler-audit` for gem vulnerability checks.
- **CI**: A full CI check can be run locally using `bin/ci`.

## Development Notes

- **Email**: In development, sent emails can be viewed at `/letter_opener`.
- **Infrastructure**: The project uses Rails 8's "Solid" stack, replacing Redis with SQLite-backed alternatives for Caching, Queuing, and Pub/Sub.