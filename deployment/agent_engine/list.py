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

import os
import vertexai
import logging
from vertexai import agent_engines
from dotenv import load_dotenv, set_key, find_dotenv, unset_key
from vertexai.preview.reasoning_engines import AdkApp


load_dotenv()

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)



vertexai.init(
    project=os.getenv("GOOGLE_CLOUD_PROJECT"),
    location=os.getenv("GOOGLE_CLOUD_LOCATION"),
    staging_bucket="gs://" + os.getenv("GOOGLE_CLOUD_PROJECT")+"-"+os.getenv("AGENT_ENGINE_NAME")+"",
)


logger.info("Listing app...")

remote_app = agent_engines.list(filter=f'display_name="{os.getenv("AGENT_ENGINE_NAME")}"')

logging.debug(f"Remote app: {next(remote_app).display_name}")
