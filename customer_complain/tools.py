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

import io
import vertexai
import os
import asyncio
import requests
from google import genai
from google.genai import types
from google.cloud import storage

from google.adk.tools.tool_context import ToolContext
from google.genai.types import GenerateContentConfig, Part as part2

from google.cloud import storage
from vertexai.generative_models import GenerativeModel, Part


async def generate_voucher(tool_context: ToolContext, voucher_id: str, total_amount: str) -> dict:
    
    try:      
        client = genai.Client()

        response = client.models.generate_images(
            model='imagen-4.0-generate-001',
            prompt=f"Generate a single image which represents the voucher for the user. The voucher should include the following information: Voucher ID {voucher_id}, Voucher Amount {total_amount}, in the ICA supermarket style in Sweden",
            config=types.GenerateImagesConfig(
                number_of_images=1,
                include_rai_reason=True,
                output_mime_type='image/png',
            )
        )

        image_bytes = response.generated_images[0].image.image_bytes
        blob_part = part2.from_bytes(data=image_bytes, mime_type="image/png")
        
        try:
            res = await tool_context.save_artifact(filename="image.png", artifact=blob_part)
            return {
                'status': 'success',
                'result': res
            }
        except Exception as e:
            error_message = f"Failed to save artifact: {e}"
            print(error_message)
            return {"status": "error", "error_message": error_message}
    
    except ValueError as ve:
        print(f"Configuration error: {ve}")
        return {"status": "error", "error_message": str(ve)}



def get_items_from_image(orderid: str, product_name: str) -> str:
    """
    Performs multimodal analysis on an image stored in Google Cloud Storage (GCS)
    using the Gemini 2.5 Flash model on Vertex AI.

    This is typically used for image classification 
    or visual question answering tasks.

    Args:
        orderid: The unique identifier (e.g., "ORD2025001") used to construct 
                 the GCS path for the image: "gs://customer-complains/{orderid}.png".

    Returns:
        The generated text response from the Gemini model as a json object that holds the items in the box
    """

    try:
        model= GenerativeModel("gemini-2.5-flash")
        prompt = "Is there a " + product_name + " in the box? Answer only yes or no"
        gcs_uri = "gs://customer-complains/" + orderid + ".png"
        image_part = Part.from_uri(uri=gcs_uri, mime_type="image/png")
        responses = model.generate_content([image_part, prompt])
        return responses.text
    except Exception as e:
        print(f"Error classifying image from URI {gcs_uri}: {e}")
        return "Classification failed."



async def load_delivery_image(tool_context: ToolContext, orderid: str) -> dict:
    """
    Loads an image from a URL

    Args:
        orderid: The unique identifier (e.g., "ORD2025001") used to construct 
        the GCS path for the image: "gs://customer-complains/{orderid}.png".

    Returns:
        The image from GCS
    """

    print("---------- Fetching GCS image -------------")


    client = storage.Client()
    bucket = client.bucket("customer-complains")
    blob = bucket.blob(f"{orderid}.png")

    image_bytes = blob.download_as_bytes()

    print(f"---------- Image retrieved from GCS-------------: {len(image_bytes)}")


    # Create a Part object for the image
    image_part = part2.from_bytes(mime_type="image/png", data=image_bytes) # Adjust mime_type as needed

    print(f"---------- Image part created-------------")

    # Save the image as an ADK artifact
    res = await tool_context.save_artifact(artifact=image_part, filename="delivery_imag.png")

    print(f"---------- tool_context.save_artifact done-------------")

    return {
        'status': 'success',
        'result': res
    }

 



# async def load_delivery_image(tool_context: ToolContext, orderid: str) -> dict:
#     """
#     Loads an image from a URL

#     Args:
#         orderid: The unique identifier (e.g., "ORD2025001") used to construct 
#         the GCS path for the image: "gs://customer-complains/{orderid}.png".

#     Returns:
#         The image from GCS
#     """

#     try:
#         async with aiohttp.ClientSession() as session:
#             async with session.get("https://storage.googleapis.com/customer-complains/" + orderid + ".png") as response:
#                 response.raise_for_status()
#                 image_bytes = await response.read()

#         blob_part = Part.from_data(data=image_bytes, mime_type="image/png")

#         print(f"---------------- DEBUG ------------------")
#         print(blob_part)

#         try:
#             res = await tool_context.save_artifact(filename="retrieved_image.png", artifact=blob_part)

#             print(f"---------------- DEBUG ------------------")
#             print(res)

#             return {
#                 'status': 'success',
#                 'result': res
#             }
#         except Exception as e:
#             error_message = f"Failed to save artifact: {e}"
#             print(error_message)
#             return {"status": "error", "error_message": error_message}

#     except Exception as e:
#         print(f"Error classifying image from URI: {e}")
#         return "Classification failed."


