# 🧠 AI Terminal Lab — Dockerized Multi-Model Environment

**Author:** Skills Nwokolo Anthony
**Purpose:** Isolated Docker containers running official AI CLI tools (Claude, Gemini) with shared workspace
**Last Updated:** 18th November 2025

---

## ⚙️ 1. Overview

This environment provides a **fully modular AI workspace** using Docker containers to run official AI CLI tools (installed via npm) with shared access to your projects and contexts.

**How it works:**
* Official CLI tools (like `@anthropic/claude-cli`) run **inside Docker containers**
* Each container makes **API calls to cloud services** (Anthropic, Google, etc.)
* All containers share a **mounted volume** (`~/ai:/workspace`) for unified access to files
* Authentication happens via **browser OAuth** (one-time per container)

**Folder structure:**
* 🧱 **ai/config/** → Git-tracked, reproducible base (Dockerfile, scripts, sessions.json)
* 💬 **ai/contexts/** → project-specific context files, prompt histories, logic blocks
* 🧩 **ai/projects/** → per-project workspaces
* 🧠 **sessions.json** → registry documenting which model/role handles which project

---

## 📁 2. Folder Structure

```bash
ai/
├── contexts/              # Stores markdown logic and project-specific context
│   ├── revisemate.md
│   ├── frontend.md
│   └── ...
│
├── projects/              # Agent or project folders (not versioned)
│   ├── revisemate/
│   ├── ui-builder/
│   └── ...
│
└── config/                # Tracked repository (core setup)
    ├── .git/
    ├── .gitignore
    ├── Dockerfile
    ├── docker-compose.yml
    ├── sessions.json
    ├── models/            # Base model awareness prompts (optional)
    │   ├── claude-base.md
    │   └── gemini-base.md
    └── scripts/
        ├── rebuild.sh
        └── flatten.sh
```

✅ **Only `config/` is version-controlled.**
Everything else (`contexts/`, `projects/`) remains local, lightweight, and rebuildable.

---

## ⚙️ 3. Sessions Registry

`config/sessions.json` is a **documentation file** that helps you track which model/container handles which project and what context files are relevant.

**Example:**

```json
{
  "revisemate": {
    "model": "claude",
    "role": "project_manager",
    "description": "Main project management for RevisionMate app",
    "contexts": [
      "../contexts/revisemate.md",
      "../contexts/frontend.md"
    ]
  },
  "daily-assistant": {
    "model": "gemini",
    "role": "general_assistant",
    "description": "Quick queries, summaries, daily tasks",
    "contexts": [
      "../contexts/daily-notes.md"
    ]
  }
}
```

**Fields:**

* **Key** = Session name (project or purpose)
* `"model"` = Which CLI tool to use (`claude`, `gemini`)
* `"role"` = Your mental model for what this session does
* `"description"` = Human-readable purpose
* `"contexts"` = Array of relevant context file paths
* A session can reference **multiple context files**

---

## 🧠 4. Model Usage

| Model      | Container Role       | Typical Use Cases                                     |
| ---------- | -------------------- | ----------------------------------------------------- |
| **Claude** | 🧠 Main orchestrator | Complex logic, coding tasks, project management       |
| **Gemini** | 🗓️ Quick assistant   | Fast queries, summaries, daily tasks, brainstorming   |

**Workflow pattern:**
* Run Claude in one tmux pane for main development work
* Run Gemini in another tmux pane for quick questions without interrupting Claude
* Both containers share the same `/workspace` volume for seamless file access

---

## 🧩 5. Managing Sessions

Since `sessions.json` is just a documentation/tracking file, you manage it manually:

| Task                  | How to do it                                                    |
| --------------------- | --------------------------------------------------------------- |
| 🆕 **Create session** | Add a new JSON entry with model, role, description, and contexts |
| 🔍 **Find session**   | Open the file: `cat config/sessions.json` or search it          |
| ➕ **Add context**     | Append another file path to the `"contexts"` array             |
| 🗑️ **Remove session** | Delete the JSON entry for that session                          |

You can manually edit `sessions.json` or create helper scripts to manage it programmatically.

---

## 🧰 6. Scripts Overview

| Script       | Description                                         |
| ------------ | --------------------------------------------------- |
| `rebuild.sh` | Rebuilds Docker image (`ai-base`)                   |
| `flatten.sh` | (Optional) Cleans parent containers in Sway WM      |

Example rebuild:

```bash
cd ~/ai/config/scripts
./rebuild.sh
```

**Note:** Authentication for Claude/Gemini CLI tools happens via **browser OAuth** when you first run the CLI in each container, not via exported API keys.

---

## 🐋 7. Docker Setup

### 🧱 Build Base Image

```bash
cd ~/ai/config
docker build -t ai-base .
```

**Note:** If you see `<none>` for the image name after building:
```bash
docker tag <IMAGE_ID> ai-base:latest
docker images  # Verify the tag
```

### 🧩 Launch Containers

Start containers for each AI model you want to use:

```bash
# Claude container
docker run -it --name claude \
  -v ~/ai:/workspace \
  ai-base bash

# Gemini container (in a different terminal/tmux pane)
docker run -it --name gemini \
  -v ~/ai:/workspace \
  ai-base bash
```

**What happens:**
* Each container runs a bash shell
* Inside, you manually run `claude` or `gemini` commands
* First time: You'll authenticate via browser OAuth
* All containers share `/workspace` which maps to `~/ai` on your host

**Inside each container:**
```bash
cd /workspace
claude  # Launches Claude CLI (authenticate on first run)
```

---

## 🧭 8. tmux Layout (Recommended)

Run multiple AI containers side-by-side using tmux panes:

| Pane | Purpose                       |
| ---- | ----------------------------- |
| 1    | Claude container (main work)  |
| 2    | Gemini container (quick Q&A)  |
| 3    | Host terminal (git, scripts)  |

```bash
# Create new tmux session
tmux new -s ai-lab

# Inside tmux, split into panes:
# Ctrl+Space "  (horizontal split)
# Ctrl+Space %  (vertical split)
```

**Detach:** `Ctrl + Space, d`
**Reattach:** `tmux attach -t ai-lab`

---

## 🧹 9. Maintenance

| Action           | Command                  |
| ---------------- | ------------------------ |
| Stop container   | `docker stop <name>`     |
| Remove container | `docker rm <name>`       |
| Remove image     | `docker rmi ai-base`     |
| Clean system     | `docker system prune -a` |

---

## 🪄 Key Points

* **Official CLI tools** run inside containers, making API calls to cloud services
* **Authentication** happens once per container via browser OAuth
* **Shared volume** (`~/ai:/workspace`) gives all containers unified file access
* **sessions.json** is version-controlled as documentation for your workflow
* **Context files** stay local and untracked - they contain your private project info
* **Base prompts** in `config/models/` can help establish consistent behavior per model


---

## ⚡ 10. Using the CLI Tools

### 🧩 Basic Usage

Inside each container, you run the official CLI command for that model:

```bash
# In the Claude container
claude

# In the Gemini container (command may vary based on Google's CLI)
gemini
# or
google-gemini
```

**First run:** You'll be prompted to authenticate via browser OAuth. Follow the link, log in, and the CLI will save your credentials for future sessions.

### 🗂️ Working with Context Files

When starting a conversation, you can reference context files from `/workspace/contexts/`:

```bash
# Example with Claude
claude
> I'm working on the project described in /workspace/contexts/revisemate.md

# Or provide context as a file attachment (if the CLI supports it)
claude --context /workspace/contexts/revisemate.md
```

### 📋 Typical Workflow

1. **Check sessions.json** to see which container/model handles your project:
   ```bash
   cat /workspace/config/sessions.json
   ```

2. **Start the appropriate container** via tmux

3. **Run the CLI** and reference your context files

4. **Work on projects** in `/workspace/projects/`

5. **Keep context files updated** as your project evolves

### 🔄 Switching Contexts

To switch between different projects/contexts:

1. Exit the current CLI session (or open a new tmux pane)
2. Reference different context files from `/workspace/contexts/`
3. Update `sessions.json` to document the change

### 🧰 Helper Scripts (Optional)

You can create wrapper scripts in `config/scripts/` to automate common tasks:

```bash
#!/bin/bash
# start-session.sh - Helper to launch a session
SESSION_NAME=$1
MODEL=$(jq -r ".$SESSION_NAME.model" /workspace/config/sessions.json)
CONTEXTS=$(jq -r ".$SESSION_NAME.contexts[]" /workspace/config/sessions.json)

echo "Starting $MODEL for session: $SESSION_NAME"
echo "Relevant contexts: $CONTEXTS"

# Launch the CLI
$MODEL
```

### 📊 Logs and History

* CLI tools typically store conversation history in their own config directories
* Consider using `/workspace/logs/` for any custom logging
* Add `*.log` to `.gitignore` to keep logs local

---

## 🚀 11. Advanced Tips

### Docker Compose (Optional)

Create `docker-compose.yml` to manage multiple containers:

```yaml
version: '3.8'
services:
  claude:
    image: ai-base
    container_name: claude
    stdin_open: true
    tty: true
    volumes:
      - ~/ai:/workspace

  gemini:
    image: ai-base
    container_name: gemini
    stdin_open: true
    tty: true
    volumes:
      - ~/ai:/workspace
```

Then: `docker-compose up -d` to start all containers.

### Persistent Authentication

Once authenticated in a container, credentials are typically stored in the container's filesystem. To preserve them:

1. **Commit the container** after authentication:
   ```bash
   docker commit claude claude-authenticated
   ```

2. **Use the authenticated image** for future runs:
   ```bash
   docker run -it --name claude-new -v ~/ai:/workspace claude-authenticated bash
   ```

### Custom Base Prompts

Create model-specific base prompts in `config/models/`:

**claude-base.md:**
```markdown
You are working in a containerized development environment.

Project structure:
- /workspace/contexts/ - project context files
- /workspace/projects/ - active projects
- /workspace/config/sessions.json - session registry

When asked about a project, first check if there's a context file for it.
```

Reference this in your sessions by copying it into the chat or configuring your CLI to use it automatically.
