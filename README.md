# Python AI Training Course

This repository contains materials for the Python AI training course, taking you from Python Zero to MCP Hero.

## Setting up your Environment with UV

[UV](https://github.com/astral-sh/uv) is a fast Python package installer and resolver that can be used as an alternative to pip. This project uses uv for dependency management.

### Installing UV

First, install uv using the appropriate method for your operating system:

#### On Windows:
```powershell
pip install uv
```

#### On macOS/Linux:
```bash
pip install uv
```

Alternatively, you can use the official installer:

#### On Windows:
```powershell
(Invoke-WebRequest -Uri https://github.com/astral-sh/uv/releases/latest/download/uv-installer.ps1 -UseBasicParsing).Content | python -
```

#### On macOS/Linux:
```bash
curl -LsSf https://github.com/astral-sh/uv/releases/latest/download/uv-installer.sh | sh
```

### Setting up the Project

1. Clone the repository:
```bash
git clone <repository-url>
cd python-ai-course-python-zero-mcp-hero
```

2. Create a virtual environment and install dependencies using uv:
```bash
uv venv
```

3. Activate the virtual environment:
   - On Windows: `.venv\Scripts\activate`
   - On macOS/Linux: `source .venv/bin/activate`

4. Install project dependencies:
```bash
uv pip install -e .
```

This will install all dependencies specified in the pyproject.toml file.

### Installing Jupyter using UV

After setting up your environment, install Jupyter using uv:

```bash
uv pip install jupyter notebook
```

You can also install JupyterLab if you prefer:

```bash
uv pip install jupyterlab
```

### Running Jupyter Notebooks

Once Jupyter is installed, you can start a Jupyter notebook server:

```bash
jupyter notebook
```

Or, if you prefer JupyterLab:

```bash
jupyter lab
```

This will open a browser window with the Jupyter interface, allowing you to create and run notebooks.

### Managing Dependencies

The project dependencies are managed through the `pyproject.toml` file. If you need to add a new dependency:

1. Add it to the `pyproject.toml` file
2. Run:
```bash
uv pip install -e .
```

To update all dependencies to their latest versions according to the constraints in pyproject.toml:

```bash
uv pip install -e . --upgrade
```

## Additional Resources

- [UV Documentation](https://github.com/astral-sh/uv/blob/main/README.md)
- [Jupyter Documentation](https://jupyter.org/documentation)
