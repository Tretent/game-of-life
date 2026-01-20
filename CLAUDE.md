# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Web-based implementation of **Conway's Game of Life** - Ruby on Rails 8.1 with Ruby 4.0.1.

Based on requirements from [Extendi Game of Life](https://github.com/extendi/game-of-life).

### Key Features
- User authentication (email/password)
- File upload for initial patterns (grid auto-sizes)
- Grid interaction: manual toggle
- Simulation controls: next step, previous step, auto-play/pause, reset
- Generation scrubbing (navigate backward/forward through history)
- Server-side evolution calculations
- Real-time UI updates via Turbo/Stimulus

### Game Rules (Finite Grid)
1. Live cell with <2 neighbors dies (underpopulation)
2. Live cell with 2-3 neighbors survives
3. Live cell with >3 neighbors dies (overpopulation)
4. Dead cell with exactly 3 neighbors becomes alive (reproduction)

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
- **Styling**: Tailwind CSS
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Deployment**: Kamal (Docker-based)

## Development Tools

- Letter Opener Web available at `/letter_opener` in development for viewing sent emails
