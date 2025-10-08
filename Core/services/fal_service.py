"""
fal.ai Service Integration
Handles communication with fal.ai API for image editing
"""
import os
import fal_client
from dotenv import load_dotenv
import logging
from typing import Optional, Dict, Any
import base64
import aiofiles

load_dotenv()
logger = logging.getLogger(__name__)

FAL_API_KEY = os.getenv("FAL_API_KEY")

# Configure fal_client with API key
os.environ["FAL_KEY"] = FAL_API_KEY


class FalService:
    """
    Service class for interacting with fal.ai API
    """
    
    # Available models
    MODELS = {
        "seedream": "fal-ai/bytedance/seedream/v4/edit",
        "nano_banana": "fal-ai/nano-banana/edit",
        "flux_dev": "fal-ai/flux-1/dev/image-to-image"
    }
    
    def __init__(self, model: str = "seedream"):
        """
        Initialize FalService with specified model
        
        Args:
            model: Model identifier (seedream, nano_banana, or flux_dev)
        """
        self.model = self.MODELS.get(model, self.MODELS["seedream"])
        logger.info(f"FalService initialized with model: {self.model}")
    
    async def edit_image(
        self,
        image_path: str,
        prompt: str,
        **kwargs
    ) -> Dict[str, Any]:
        """
        Edit an image using fal.ai API
        
        Args:
            image_path: Path to the input image file
            prompt: Text description of desired edits
            **kwargs: Additional model-specific parameters
            
        Returns:
            Dict containing the result with 'url' and 'request_id'
            
        Raises:
            Exception: If API call fails
        """
        try:
            logger.info(f"Starting image edit with prompt: {prompt[:50]}...")
            
            # Read image and convert to base64 or upload
            image_url = await self._prepare_image(image_path)
            
            # Prepare arguments based on model
            arguments = self._prepare_arguments(image_url, prompt, **kwargs)
            
            # Call fal.ai API
            logger.info(f"Calling fal.ai API with model: {self.model}")
            result = await self._call_fal_api(arguments)
            
            logger.info("Image edit completed successfully")
            return result
            
        except Exception as e:
            logger.error(f"Error in edit_image: {str(e)}")
            raise
    
    async def _prepare_image(self, image_path: str) -> str:
        """
        Prepare image for API call (convert to URL or base64)
        
        Args:
            image_path: Local path to image
            
        Returns:
            Image URL or data URI
        """
        try:
            # For production, you might want to upload to a CDN
            # For now, we'll use base64 encoding
            async with aiofiles.open(image_path, 'rb') as f:
                image_data = await f.read()
            
            # Convert to base64
            base64_image = base64.b64encode(image_data).decode('utf-8')
            
            # Determine MIME type
            mime_type = "image/jpeg"
            if image_path.lower().endswith('.png'):
                mime_type = "image/png"
            elif image_path.lower().endswith('.webp'):
                mime_type = "image/webp"
            
            return f"data:{mime_type};base64,{base64_image}"
            
        except Exception as e:
            logger.error(f"Error preparing image: {str(e)}")
            raise
    
    def _prepare_arguments(
        self,
        image_url: str,
        prompt: str,
        **kwargs
    ) -> Dict[str, Any]:
        """
        Prepare API arguments based on model
        
        Args:
            image_url: URL or data URI of the image
            prompt: Edit prompt
            **kwargs: Additional parameters
            
        Returns:
            Dictionary of API arguments
        """
        # Base arguments for flux/dev/image-to-image
        arguments = {
            "image_url": image_url,
            "prompt": prompt,
            "strength": kwargs.get("strength", 0.75),
            "guidance_scale": kwargs.get("guidance_scale", 7.5),
            "num_inference_steps": kwargs.get("num_inference_steps", 28),
            "num_images": kwargs.get("num_images", 1),
            "enable_safety_checker": kwargs.get("enable_safety_checker", True),
        }
        
        # Add model-specific parameters
        if "seedream" in self.model:
            arguments = {
                "image_urls": [image_url],  # Seedream expects array of image URLs
                "prompt": prompt,
                "num_inference_steps": kwargs.get("num_inference_steps", 50),
            }
        elif "nano-banana" in self.model:
            arguments = {
                "image_urls": [image_url],  # Nano Banana expects array of image URLs
                "prompt": prompt,
            }
        
        return arguments
    
    async def _call_fal_api(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """
        Make async call to fal.ai API
        
        Args:
            arguments: API arguments
            
        Returns:
            API response with image URL
        """
        try:
            # Subscribe to the API (this will handle async execution)
            handler = await fal_client.submit_async(
                self.model,
                arguments=arguments
            )
            
            logger.info(f"Job submitted to fal.ai, request_id: {handler.request_id}")
            
            # Wait for result
            result = await handler.get()
            
            # Extract image URL from result
            if isinstance(result, dict):
                # Handle different response formats
                if "images" in result and len(result["images"]) > 0:
                    image_url = result["images"][0].get("url")
                elif "image" in result:
                    image_url = result["image"].get("url")
                else:
                    raise ValueError("Unexpected response format from fal.ai")
                
                return {
                    "url": image_url,
                    "request_id": handler.request_id,
                    "raw_result": result
                }
            else:
                raise ValueError("Invalid response from fal.ai API")
                
        except Exception as e:
            logger.error(f"fal.ai API call failed: {str(e)}")
            raise
    
    async def get_job_status(self, request_id: str) -> Dict[str, Any]:
        """
        Get status of a fal.ai job
        
        Args:
            request_id: fal.ai request ID
            
        Returns:
            Job status information
        """
        try:
            status = await fal_client.status_async(
                self.model,
                request_id,
                with_logs=True
            )
            return status
        except Exception as e:
            logger.error(f"Error getting job status: {str(e)}")
            raise


# Model instances cache
_fal_service_instances = {}


def get_fal_service(model: str = "seedream") -> FalService:
    """
    Get or create FalService instance for specified model
    
    Args:
        model: Model to use (seedream, nano_banana, or flux_dev)
        
    Returns:
        FalService instance
    """
    global _fal_service_instances
    if model not in _fal_service_instances:
        _fal_service_instances[model] = FalService(model=model)
    return _fal_service_instances[model]
