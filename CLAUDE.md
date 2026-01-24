
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Web-based implementation of **Conway's Game of Life** - Ruby on Rails 8.1 with Ruby 4.0.1.

Based on requirements from [Extendi Game of Life](https://github.com/extendi/game-of-life).

### Key Features
- User authentication (sign in and sign up processes)
- The sign up process comprehends email verification
- File upload for initial patterns with validation
- Grid interaction: cell toggling via click (dimensions read-only)
- Simulation controls: Play, Pause, Next, Reset (music player style)
- Server-side evolution calculations
- Real-time UI updates via Turbo/Stimulus

### Game Rules (Finite Grid)
1. Live cell with <2 neighbors dies (underpopulation)
2. Live cell with 2-3 neighbors survives
3. Live cell with >3 neighbors dies (overpopulation)
4. Dead cell with exactly 3 neighbors becomes alive (reproduction)

## Feature Specifications

### 1. User Authentication
The application includes complete authentication flows:
- **Sign Up**: New users register with email and password
- **Sign In**: Existing users authenticate with credentials
- **Session Management**: Authenticated sessions persist across requests

### 2. File Upload for Initial Patterns

#### File Format
Pattern files must follow this exact structure:
```text
Generation 3:
4 8
........
....*...
...**...
........
```

Where:
- `.` represents a dead cell
- `*` represents an alive cell
- First line: `Generation N:` (with colon)
- Second line: `rows columns` (space-separated)
- Following lines: grid pattern (one row per line)

#### Validation Rules
The system validates uploaded files against these constraints:

**Generation Constraints:**
- Must be greater than 0
- Must be less than 1000

**Dimension Constraints:**
- Rows must be greater than 0
- Rows must be less than 100
- Columns must be greater than 0
- Columns must be less than 100

**Grid Coherence:**
- The number of grid rows must match the declared row count
- Each grid row must have exactly the declared column count
- Only `.` (dead) and `*` (alive) characters are valid in the grid

### 3. Grid Interaction

After a file is uploaded:
- **Grid dimensions are read-only** - cannot be modified manually
- **Grid is displayed as a matrix** - visual representation of the pattern
- **Cells are interactive** - click any cell to toggle between alive/dead states
- **Changes are reflected immediately** - UI updates in real-time

The grid dimensions come exclusively from the uploaded file's second line.

### 4. Simulation Controls

Controls are styled like a music player with four primary buttons:

- **Play**️ &#9205; - Starts automatic generation evolution at one-second intervals.
- **Pause** &#9208; - Stops automatic evolution (preserves current state)
- **Next** &#9197; - Advances exactly one generation manually
- **Reset** &#9198; - Returns the grid to its initial uploaded state

Control states:
- During auto-play: Play, Next, and Reset are disabled; only Pause is active
- When paused/stopped: All controls except Pause are enabled

## Common Commands

### Development
- `bin/setup` - Install dependencies and prepare database, then start server
- `bin/dev` - Start development server (runs `rails server`)

### Testing
- `bin/rails test` - Run all tests
- `bin/rails test test/models/foo_test.rb` - Run a specific test file
- `bin/rails test test/models/foo_test.rb:42` - Run a specific test by line number
- `bin/rails test:system` - Run system tests (Capybara + Selenium)

### Linting & Security
- `bin/rubocop` - Run RuboCop (uses rubocop-rails-omakase style)
- `bin/rubocop -a` - Auto-fix RuboCop offenses
- `bin/brakeman` - Static security analysis
- `bin/bundler-audit` - Audit gems for known vulnerabilities
- `bin/importmap audit` - Audit importmap for vulnerabilities

### CI
- `bin/ci` - Run full CI suite (setup, rubocop, security audits, tests)

### Database
- `bin/rails db:prepare` - Create/migrate database
- `bin/rails db:reset` - Drop, create, and seed database

## Architecture

- **Database**: SQLite3 (stored in `storage/` directory)
- **Asset Pipeline**: Propshaft
- **JavaScript**: Importmap with Hotwire (Turbo + Stimulus)
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Deployment**: Kamal (Docker-based)

## Development Tools

- Letter Opener Web available at `/letter_opener` in development for viewing sent emails
