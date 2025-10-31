# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


from google.adk.agents import Agent, SequentialAgent, LlmAgent
from google.adk.tools.agent_tool import AgentTool
from google.adk.tools.load_artifacts_tool import load_artifacts_tool
from .tools import get_items_from_image, generate_voucher
from toolbox_core import ToolboxSyncClient

toolbox = ToolboxSyncClient("https://toolbox-customer-complains-921470220241.us-central1.run.app/")
#toolbox = ToolboxSyncClient("http://127.0.0.1:5000")

# Load all the tools
tools = toolbox.load_toolset('my_bq_toolset')

product_retrieval_agent = LlmAgent(
    name="product_retrieval_agent",
    model="gemini-2.5-flash",
    description=(
        "Agent to order information from the tool, based information passed by the user. The user should prompted to provide order_id and product_name."
    ),
    instruction=(
        "You are a helpful agent who will retrieve order_id, product_id, product_name and the quantity. Ask the user to provide both order_id and product_name that is missing from the delivery. Use the tools to answer the question, by passing in the strict order, the order_id and the product_name. Display all information retrieved by the tool as a JSON object. Pass the product_name to the next agent."
    ),
    tools=tools,
)



insert_voucher_agent = LlmAgent(
    name="insert_voucher_agent",
    model="gemini-2.5-flash",
    description=(
        "Agent to insert a voucher row with the tool, based information passed by the root agent."
    ),
    instruction=(
        "You are a database agent who will insert the voucher_id, customer_id, order_id and the total_amount. "
    ),
    tools=tools,
)



root_agent = Agent(
    model="gemini-2.5-flash",
    name='customer_complain',
    instruction="""
      You are an expert customer service agant. Users will contact you if they have receievd a delivery where an item is missing.
      Welcome the user and ask for an order_id and a the name of the product that was missing from the delivery.
      You should only accept text and not any image oor video
      When the user as provided you with a valid order_id and product_name:
      1. You should check with the `product_retrieval_agent` whether the product is missing or not from the list of ordered items. If the output key from this agent contains a product_name, go to step 2 below. Otherwise, let the user know that there isn't any missing item.
         *   **If** the user does not provide an 'order_id' and a 'product_name', **then** do not go to the next step. Ask the user again until these 2 values are provided.
      2. Follow the conditional logic below:
         *   **If** the tool returns a 'product_name', **then** go to the next step to check if it is present on the picture of the package taken before delivery.
         *   **If** the tool returns a 'product_name' that does not match with the user complain, **then** respond to the user that the product was not ordered initially.
      3. Use `get_items_from_image` by passing it the order_id and the product_name to check whether the product was present on the picture of the package taken before delivery. The tool will answer with either 'yes' or 'no'.
         *   **If** the tool returns 'no', **then** go to the next step to generate a voucher for the user
         *   **If** the tool returns a 'yes', **then** respond to the user that the product was present in the delivery. Show the image by from the following HTML code: <img src="https://storage.googleapis.com/customer-complains/'order_id'.png" />
      4. You are now creating a voucher for the user. Generate a voucher_id as a string. Generate also a total_amount as a string which matches the product value. This total_amount should be in Swedish Krona (SEK).
      5. Use the tool `insert_voucher_agent` in order to create a voucher entry, by passing voucher_id, customer_id, order_id and the total_amount.
      6. Generate a nice image of the voucher with the tool `generate_voucher` with the voucher_id, the total_amount and a product picture, with the ICA logo.
      7. Display the voucher to the user as a proof.
      You should not rely on the previous history.
    """,
    tools=[AgentTool(product_retrieval_agent), get_items_from_image, AgentTool(insert_voucher_agent), generate_voucher, load_artifacts_tool],
)