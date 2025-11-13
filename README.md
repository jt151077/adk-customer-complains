# adk-gemini-ent
Simple example of a custom Agent developed with ADK and published in GeminiEntreprise


## Pre-requisite

1. This example is meant to work with `python >= 3.12`
2. Make sure you have access to `UV` Python package manager in the command line. If not install from https://github.com/astral-sh/uv
3. Check out this repository somewhere where you have a terminal access `git clone git@github.com:jt151077/adk-customer-complains.git`
4. For this example you need a GCP Project, as the artifacts will be deployed in Agent Engine, and the GeminiEntreprise provisioned in AI Applications 


## Setup

1. If you want to use the Agent in Gemini Entreprise, make sure your GCP project is registered and supports GeminiEntreprise. To verfiy, you should have the possibility of creating an GeminiEntreprise AI Application in GCP



## Install


1. CD to the root of the project `adk-customer-complains`, provide the correct values in the `.env` file:

```shell
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=<YOUR_GCP_PROJECT_ID>
GOOGLE_CLOUD_LOCATION=<YOUR_GCP_REGION>
AGENT_ENGINE_NAME='<THE_AGENT_NAME>' ## this will be the name visible in Agent Engine
GEMINI_ENT_DISPLAY_NAME='<THE_AGENT_NAME>' ## this will be the agent name in Agent Space
GEMINI_ENT_AGENT_DESCRIPTION='<THE_AGENT_DESCRIPTION>' ## this will be the agent description in Agent Space
```

2. At the root folder, execute the following commands:

```shell
uv venv
source .venv/bin/activate
uv pip install -e .
```

3. Copy the all the queries from `./mcp_servers/bigquery/data.sql`. Open the query editor in BigQuery Studio, paste the sql queries, and click on `RUN`. This will create the dataset and some mock-up data for orders.


4. Deploy the `MCP Toolbox` container on Cloud Run, using the following command:

```shell
./mcp_servers/bigquery/deploy.sh
```


5. To test the code, you can use the graphical tool for ADK by launching:

```shell
adk web
```

This will start a webserver running on http://127.0.0.1:8000. By pointing your webbrowser to this address, you can test the code.


6. You can also test the Agent from the command line and/or deploy it via the following commands:

```shell
uv run customer_complain/test_local.py
uv run deployment/agent_engine/deploy.py
```

> When the deploy script is finished, it will update the `.env` file with the new Agent Engine Resource Name (in the form): `GEMINI_ENT_AGENT_NAME=projects/<PROJECT_NUMBER>/locations/us-central1/reasoningEngines/6540449315872047104`

7. Create a new `GeminiEntreprise` AI Application in the GCP console:


8. Update the `.env` file with the ID for the newly created GeminiEntreprise application (Note: the ID will displayed as you type the App name in the console):

```shell
GEMINI_ENT_APP_NAME=<YOUR_GEMINI_ENTREPRISE_APP_ID>
```


9. You can now deploy your agent hosted in Agent Engine to your latest Gemini Entreprise application, with the following command:


```shell
./deployment/gemini_ent/deploy.sh
```

> Note: This will add the `GEMINI_ENT_AGENT_NAME` value to the `.env` file. This will be picked up by default if you execute the `delete.sh` script.


10. Under the left-hand side panel, click on `Integration`, copy the link to your web app, and open it in a new tab.

11. In GeminiEntreprise, under Agents => View All Agents, you will be able to see your latest agent:


12. You can delete obsolete agents under the Agents menu in AI Application in the console. Otherwise, you combine the `list.sh` and/or `delete.sh` to clean up agents in your GeminiEntreprise

```shell
./deployment/gemini_ent/delete.sh
./deployment/gemini_ent/list.sh
```