import boto3
import logging
from typing import Optional, Any
from retrying import retry
from botocore.exceptions import ClientError

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class S3Reader:
    """A secure and fault-tolerant S3 file reader with exponential backoff"""
    
    def __init__(self, bucket: str, region_name: Optional[str] = None) -> None:
        """Initialize S3 reader with bucket and optional region"""
        self.bucket = bucket
        self.s3_client = boto3.client('s3', region_name=region_name)
    
    @retry(
        stop_max_attempt_number=3,
        wait_exponential_multiplier=1000,  # 1 second
        wait_exponential_max=10000,        # 10 seconds
        retry_on_exception=lambda e: isinstance(e, ClientError)  # This lambda function tells the retry decorator which exceptions it should retry on. If removed will retry on all exceptions
    )
    def read_file(self, key: str) -> Optional[Any]:
        """
        Read a file from S3 with exponential backoff.
        
        Args:
            key: S3 object key
        Returns:
            File content or None if file doesn't exist
        Raises:
            Exception: If max retries exceeded or fatal error occurs
        """
        try:
            logger.info(f"Attempting to read file {key} from bucket {self.bucket}")
            response = self.s3_client.get_object(Bucket=self.bucket, Key=key)
            content = response['Body'].read()
            logger.info(f"Successfully read file {key}")
            return content
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            
            if error_code == 'NoSuchKey':
                logger.error(f"File {key} not found in bucket {self.bucket}")
                return None
            elif error_code in ['NoSuchBucket', 'AccessDenied']:
                logger.error(f"Fatal error: {str(e)}")
                raise  # Fatal error, don't retry
            
            # Other ClientErrors will be retried 
            logger.warning(f"Retryable error occurred: {str(e)}")
            raise
            
        except Exception as e:
            logger.error(f"Unexpected error reading file {key}: {str(e)}")
            raise
            
        finally:
            if 'response' in locals() and 'Body' in response:  # locals shows the local variables. So here since its the finally block "response" might not exist so we check if it exists first.
                response['Body'].close()
    

    # These methods make the class work as a context manager, which allows you to use it with Python's with statement. 
    def __enter__(self) -> 'S3Reader':  # is a type hint saying it returns an S3Reader object
        # Called when entering the with block
        return self # Returns the object that will be assigned to the variable after as
    
    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        # Called when leaving the with block (even if there's an error)
        # Handles cleanup (closing the S3 client)
        if hasattr(self, 's3_client'):
            self.s3_client.close()

# Example usage:
if __name__ == "__main__":
    BUCKET_NAME = "bhvr"
    FILE_KEY = "test.txt"
    
    try:
        with S3Reader(BUCKET_NAME) as s3_reader:
            content = s3_reader.read_file(FILE_KEY)
            if content is not None:
                print(f"Successfully read file of size {len(content)} bytes. {content}")
            else:
                print("File not found")
                
    except Exception as e:
        print(f"Error reading file: {str(e)}")