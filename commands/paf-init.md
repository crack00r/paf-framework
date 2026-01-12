# /paf-init - PAF Project Initialization

> Initializes PAF in a new or existing project with Git/GitHub setup and project scaffolding.

## Step 1: Check Git Status

First execute:
```bash
git rev-parse --git-dir 2>/dev/null && echo "GIT_EXISTS" || echo "NO_GIT"
```

## Step 2: If NO Git is present

If `NO_GIT` is output, use `AskUserQuestion`:

**Header:** "Repository"
**Question:** "No Git repository found. How would you like to proceed?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Git + GitHub (Recommended) | Initializes Git and creates a GitHub repository |
| 2 | Git local only | Initializes only a local Git repository |
| 3 | Continue without Git | Starts PAF without version control |

## Step 3: Git + GitHub Setup

If Git + GitHub is selected:

```bash
git init -b main
gh --version
```

If gh is not installed: Show hint `brew install gh && gh auth login`

Get GitHub username:
```bash
GITHUB_USER=$(gh api user -q .login)
echo "GitHub User: $GITHUB_USER"
```

Ask about visibility:

**Header:** "GitHub"
**Question:** "GitHub Repository Settings:"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Public | Public repository |
| 2 | Private | Private repository |

```bash
GITHUB_USER=$(gh api user -q .login)
REPO_NAME=$(basename "$(pwd)")
gh repo create "$GITHUB_USER/$REPO_NAME" --public --source=.
```

**IMPORTANT:**
- Use `gh api user -q .login` for the correct GitHub username!
- NO `--push` here! The push happens after the Initial Commit (Step 11)!

## Step 4: Query Project Category

Ask with `AskUserQuestion`:

**Header:** "Category"
**Question:** "What kind of project would you like to create?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Web/Frontend | React, Vue, Svelte, Angular, HTML/CSS |
| 2 | Backend/API | Node.js, Python, Go, Rust, Java, .NET, PHP |
| 3 | Mobile/Desktop | Flutter, Swift, Kotlin, Electron |
| 4 | Empty (Custom) | Only basic structure without framework |

## Step 5a: Web/Frontend Selection

If Category 1 (Web/Frontend) is selected:

**Header:** "Framework"
**Question:** "Which frontend framework?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | React/Next.js | React with Next.js, TypeScript, Tailwind |
| 2 | Vue/Nuxt | Vue.js with Nuxt, TypeScript |
| 3 | Svelte/SvelteKit | Svelte with SvelteKit, TypeScript |
| 4 | Vanilla HTML/CSS/JS | Pure HTML, CSS, JavaScript without framework |

## Step 5b: Backend/API Selection

If Category 2 (Backend/API) is selected:

**Header:** "Stack"
**Question:** "Which backend stack?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | TypeScript/Node.js | Express/Fastify with TypeScript |
| 2 | Python/FastAPI | Python with FastAPI or Flask |
| 3 | Go | Go with Gin or Echo |
| 4 | Rust | Rust with Actix or Axum |

If more backend options are desired, show second question:

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Java/Spring Boot | Java with Spring Boot |
| 2 | .NET/C# | C# with ASP.NET Core |
| 3 | PHP/Laravel | PHP with Laravel |
| 4 | Ruby/Rails | Ruby on Rails |

## Step 5c: Mobile/Desktop Selection

If Category 3 (Mobile/Desktop) is selected:

**Header:** "Platform"
**Question:** "Which platform?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Flutter | Cross-Platform Mobile/Desktop with Dart |
| 2 | Swift/iOS | Native iOS/macOS App |
| 3 | Kotlin/Android | Native Android App |
| 4 | Electron | Desktop App with Web Technologies |

---

## Step 6: Create Project Scaffolding

### React/Next.js

```bash
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes
mkdir -p tests docs
```

### Vue/Nuxt

```bash
npx nuxi@latest init . --force
mkdir -p tests docs
```

### Svelte/SvelteKit

```bash
npx sv create . --template minimal --types ts
mkdir -p tests docs
```

### Vanilla HTML/CSS/JS

```bash
mkdir -p src/css src/js src/assets tests docs
```

Create `src/index.html`:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[PROJECT_NAME]</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>[PROJECT_NAME]</h1>
    <p>Created with PAF</p>
    <script src="js/main.js"></script>
</body>
</html>
```

Create `src/css/style.css`:
```css
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: system-ui, sans-serif; line-height: 1.6; padding: 2rem; }
h1 { margin-bottom: 1rem; }
```

Create `src/js/main.js`:
```javascript
// [PROJECT_NAME]
console.log('Hello from [PROJECT_NAME]!');
```

### TypeScript/Node.js

```bash
mkdir -p src tests docs
```

Create `package.json`:
```json
{
  "name": "[PROJECT_NAME_LOWERCASE]",
  "version": "0.1.0",
  "type": "module",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsx watch src/index.ts",
    "test": "vitest",
    "lint": "eslint src/"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0",
    "vitest": "^1.0.0",
    "eslint": "^8.0.0"
  }
}
```

Create `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"]
}
```

Create `src/index.ts`:
```typescript
// [PROJECT_NAME] - Created with PAF v4.4

console.log('Hello from [PROJECT_NAME]!');
```

### Python/FastAPI

```bash
mkdir -p src tests docs
python3 -m venv venv
```

Create `requirements.txt`:
```
fastapi>=0.109.0
uvicorn[standard]>=0.27.0
pydantic>=2.0.0
pytest>=7.0.0
httpx>=0.26.0
black>=24.0.0
mypy>=1.0.0
```

Create `src/main.py`:
```python
#!/usr/bin/env python3
"""[PROJECT_NAME] - FastAPI Backend"""

from fastapi import FastAPI

app = FastAPI(title="[PROJECT_NAME]", version="0.1.0")


@app.get("/")
async def root():
    return {"message": "Hello from [PROJECT_NAME]!"}


@app.get("/health")
async def health():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Go

```bash
mkdir -p cmd/server internal tests docs
```

Create `go.mod`:
```
module [PROJECT_NAME_LOWERCASE]

go 1.21
```

Create `cmd/server/main.go`:
```go
package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello from [PROJECT_NAME]!")
    })

    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        fmt.Fprintf(w, `{"status": "healthy"}`)
    })

    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

### Rust

```bash
cargo init --name [PROJECT_NAME_LOWERCASE]
mkdir -p tests docs
```

If cargo is not available:
```bash
mkdir -p src tests docs
```

Create `Cargo.toml`:
```toml
[package]
name = "[PROJECT_NAME_LOWERCASE]"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
axum = "0.7"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

Create `src/main.rs`:
```rust
use axum::{routing::get, Json, Router};
use serde_json::json;

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/health", get(health));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    println!("Server running on http://localhost:8080");
    axum::serve(listener, app).await.unwrap();
}

async fn root() -> &'static str {
    "Hello from [PROJECT_NAME]!"
}

async fn health() -> Json<serde_json::Value> {
    Json(json!({"status": "healthy"}))
}
```

### Java/Spring Boot

```bash
mkdir -p src/main/java/com/example src/main/resources src/test/java tests docs
```

Create `pom.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>
    <groupId>com.example</groupId>
    <artifactId>[PROJECT_NAME_LOWERCASE]</artifactId>
    <version>0.1.0</version>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

Create `src/main/java/com/example/Application.java`:
```java
package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @GetMapping("/")
    public String root() {
        return "Hello from [PROJECT_NAME]!";
    }

    @GetMapping("/health")
    public String health() {
        return "{\"status\": \"healthy\"}";
    }
}
```

### .NET/C#

```bash
dotnet new webapi -n [PROJECT_NAME] -o .
mkdir -p tests docs
```

If dotnet is not available, create manually:
```bash
mkdir -p src tests docs
```

### PHP/Laravel

```bash
composer create-project laravel/laravel . --prefer-dist
mkdir -p tests docs
```

If composer is not available:
```bash
mkdir -p src/public src/app tests docs
```

### Ruby/Rails

```bash
rails new . --api --database=postgresql --skip-git
mkdir -p tests docs
```

If rails is not available:
```bash
mkdir -p app lib tests docs
```

### Flutter

```bash
flutter create --org com.example --project-name [PROJECT_NAME_LOWERCASE] .
mkdir -p docs
```

If flutter is not available:
```bash
mkdir -p lib test docs
```

### Swift/iOS

```bash
mkdir -p [PROJECT_NAME] [PROJECT_NAME]Tests docs
```

Create `Package.swift`:
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "[PROJECT_NAME]",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "[PROJECT_NAME]", targets: ["[PROJECT_NAME]"])
    ],
    targets: [
        .target(name: "[PROJECT_NAME]"),
        .testTarget(name: "[PROJECT_NAME]Tests", dependencies: ["[PROJECT_NAME]"])
    ]
)
```

### Kotlin/Android

```bash
mkdir -p app/src/main/java/com/example app/src/main/res docs
```

### Electron

```bash
npm init -y
mkdir -p src tests docs
```

Create `package.json`:
```json
{
  "name": "[PROJECT_NAME_LOWERCASE]",
  "version": "0.1.0",
  "main": "src/main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder"
  },
  "devDependencies": {
    "electron": "^28.0.0",
    "electron-builder": "^24.0.0"
  }
}
```

Create `src/main.js`:
```javascript
const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
    const win = new BrowserWindow({
        width: 1200,
        height: 800,
        webPreferences: { nodeIntegration: true }
    });
    win.loadFile('src/index.html');
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
```

### Empty (Custom)

```bash
mkdir -p src tests docs
```

Create minimal files:
- `.gitignore` with standard ignores
- `README.md` with project template

---

## Step 7: Create Common Files

For ALL projects:

Create `.gitignore` (if not present):
```
# Dependencies
node_modules/
vendor/
venv/
.venv/
target/

# Build
dist/
build/
*.egg-info/

# IDE
.idea/
.vscode/
*.swp

# Environment
.env
.env.local
.env.*.local

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Coverage
coverage/
.coverage
htmlcov/
```

Create `README.md`:
```markdown
# [PROJECT_NAME]

> Created with PAF v4.4

## Setup

[Installation instructions depending on stack]

## Development

[Development instructions]

## Testing

[Test instructions]

## Deployment

[Deployment instructions]
```

---

## Step 8: Create PAF Structure

```bash
mkdir -p .paf/reviews
```

Copy templates:
- Read `~/.paf/templates/COMMS.md` and write to `.paf/COMMS.md`
- Read `~/.paf/templates/PROCESS.md` and write to `.paf/PROCESS.md`

Create `.paf/project.yaml`:
```yaml
# PAF Project Configuration
project:
  name: [PROJECT_NAME]
  type: [SELECTED_PROJECT_TYPE]
  created: [DATE]
  repository: [GITHUB_URL or "No Git repository"]

settings:
  model: claude-opus-4-5-20251101
  language: en
  auto_labels: true
  parallel_review: true
```

---

## Step 9: GitHub Integration (REQUIRED for GitHub projects!)

If Git + GitHub is present:

**Header:** "GitHub Setup"
**Question:** "Should Gideon set up the GitHub integration?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Yes (Recommended) | Gideon creates 91 labels, 7 boards, templates (approx. 3-5 min) |
| 2 | No | Can be done later with /paf-setup-github |

**If Yes: SPAWN GIDEON (GitHub Setup Agent):**

```
1. Notify the user:
   "⚙️ Gideon (GitHub Setup Agent) is starting...
   This takes approximately 3-5 minutes. Please wait."

2. Spawn Gideon WITH TIMEOUT:
   mcp__nested-subagent__Task({
     description: "Gideon GitHub Setup",
     agentName: "gideon",
     prompt: `You are Gideon, GitHub Setup Agent.
     Read: ~/.paf/agents/utility/gideon.md
     Task: Set up the GitHub system for this repository.
     Execute all 8 phases.
     Document in .paf/GITHUB_SYSTEM.md.
     Write status to .paf/COMMS.md.`,
     model: "sonnet",
     allowWrite: true,
     permissionMode: "acceptEdits",
     timeout: 600000
   })

3. After Gideon (successful OR timeout):
   → Check if .paf/GITHUB_SYSTEM.md exists
   → If yes: Gideon was successful, done
   → If no or incomplete: Start recovery (see below)
```

**RECOVERY ON TIMEOUT (automatic, no user interaction):**

If Gideon times out or is incomplete, perform recovery:

```
1. CHECK STATUS - What already exists?

   # Count labels
   EXISTING_LABELS=$(gh label list --limit 200 --json name -q 'length')

   # Count projects
   EXISTING_PROJECTS=$(gh project list --owner [USER] --format json -q 'length' 2>/dev/null || echo "0")

   # Check issue templates
   TEMPLATES_EXIST=$(ls .github/ISSUE_TEMPLATE/*.md 2>/dev/null | wc -l)

   # Check GitHub Actions
   WORKFLOWS_EXIST=$(ls .github/workflows/*.yml 2>/dev/null | wc -l)

2. CREATE ONLY MISSING LABELS

   If EXISTING_LABELS < 80:
     # Get list of existing labels
     EXISTING=$(gh label list --limit 200 --json name -q '.[].name')

     # Create only labels that are NOT in EXISTING
     # Example: Check before each label create if it exists
     if ! echo "$EXISTING" | grep -q "^priority:critical$"; then
       gh label create "priority:critical" --color "FF0000" ...
     fi
     # ... (for all 91 PAF labels)

3. CREATE ONLY MISSING PROJECTS

   If EXISTING_PROJECTS < 7:
     # Check which boards exist
     EXISTING_BOARDS=$(gh project list --owner [USER] --format json -q '.[].title')

     # Create only missing ones
     if ! echo "$EXISTING_BOARDS" | grep -q "Sprint Backlog"; then
       gh project create --owner [USER] --title "Sprint Backlog"
     fi
     # ... (for all 7 boards)

4. CREATE ONLY MISSING TEMPLATES

   If TEMPLATES_EXIST < 8:
     mkdir -p .github/ISSUE_TEMPLATE
     # Check which exist and create only missing
     [ ! -f .github/ISSUE_TEMPLATE/bug_report.md ] && Write(bug_report.md)
     [ ! -f .github/ISSUE_TEMPLATE/feature_request.md ] && Write(feature_request.md)
     # ... (for all 8 templates)

5. CREATE ONLY MISSING WORKFLOWS

   If WORKFLOWS_EXIST < 6:
     mkdir -p .github/workflows
     # Check which exist and create only missing
     [ ! -f .github/workflows/paf-auto-label.yml ] && Write(paf-auto-label.yml)
     # ... (for all 6 workflows)

6. CREATE/UPDATE GITHUB_SYSTEM.MD

   If .paf/GITHUB_SYSTEM.md does not exist or is incomplete:
     Write(.paf/GITHUB_SYSTEM.md) with current status
```

**IMPORTANT for Recovery:**
- ALWAYS check what exists first (gh label list, ls, etc.)
- Create ONLY missing items
- No duplicates!
- No user interaction needed
- At the end create GITHUB_SYSTEM.md with final status

---

## Step 10: Install Dependencies

Depending on project type:

| Type | Command |
|------|---------|
| Node.js/React/Vue/Svelte/Electron | `npm install` |
| Python | `source venv/bin/activate && pip install -r requirements.txt` |
| Go | `go mod tidy` |
| Rust | `cargo build` |
| Java | `./mvnw install` or `mvn install` |
| .NET | `dotnet restore` |
| PHP | `composer install` |
| Ruby | `bundle install` |
| Flutter | `flutter pub get` |

---

## Step 11: Initial Commit

```bash
git add -A
git commit -m "Initial commit - [PROJECT_NAME]

Stack: [PROJECT_TYPE]
Created with PAF v4.4

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push 2>/dev/null || true
```

---

## Step 12: Completion

```
PAF - Project successfully initialized!

Project:     [PROJECT_NAME]
Type:        [PROJECT_TYPE]
Repository:  [GITHUB_URL]
GitHub:      [LABELS/BOARDS STATUS]

Created structure:
  src/           Source Code
  tests/         Tests
  docs/          Documentation
  .paf/          PAF Configuration

Next steps:
┌──────────────┬──────────────────────────────────────────┐
│ Command      │ Description                              │
├──────────────┼──────────────────────────────────────────┤
│ /paf-cto     │ CTO Agent - describe your idea           │
│ /paf-help    │ PAF Help System                          │
│ /paf         │ Show status and options                  │
└──────────────┴──────────────────────────────────────────┘
```

---

## IMPORTANT - Order

1. Check Git status
2. If Git is missing: ASK user
3. ASK for project category
4. ASK for specific framework
5. Create scaffolding
6. Create common files
7. Create PAF structure
8. Offer GitHub integration
9. Install dependencies
10. Initial commit
11. Show summary
