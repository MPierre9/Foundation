import unittest
from unittest.mock import patch, Mock
from botocore.exceptions import ClientError
import boto3

from pythonsamples.S3Reader import S3Reader

class TestS3Reader(unittest.TestCase):
    """
    Test suite for S3Reader class. Uses unittest framework with mocking to test S3 operations
    without actually connecting to AWS.
    """

    def setUp(self):
        """
        setUp runs before each test method. It's used to establish a known state
        before each test runs, ensuring each test starts with the same conditions.
        """
        self.bucket = "test-bucket"
        self.key = "test-key.txt"
        self.test_content = b"test content"  # Using bytes for binary file content

    # @patch replaces the specified object (boto3.client) with a Mock during the test.
    # This prevents actual AWS calls and lets us control the behavior.
    # The mock object is automatically passed as an argument to the test method.
    @patch('boto3.client')
    def test_successful_read(self, mock_boto3_client):
        """
        Test successful file read from S3.
        Demonstrates basic mock setup and verification.
        """
        # Mock setup:
        # 1. Create a mock S3 client
        # 2. Create a mock response body
        # 3. Configure the mocks to return our test data
        mock_s3 = Mock()
        mock_body = Mock()
        
        # return_value sets a fixed value that will be returned when the mock is called
        # Use this when you want the same response every time
        mock_body.read.return_value = self.test_content
        mock_s3.get_object.return_value = {'Body': mock_body}
        mock_boto3_client.return_value = mock_s3

        # Execute the code being tested
        # Using context manager (with) to ensure proper cleanup
        with S3Reader(self.bucket) as reader:
            content = reader.read_file(self.key)

        # Assertions verify that the code behaved as expected
        # 1. Check the returned content matches what we expected
        # 2. Verify the mock was called with correct parameters
        # 3. Ensure cleanup (close) was called
        self.assertEqual(content, self.test_content)
        mock_s3.get_object.assert_called_once_with(Bucket=self.bucket, Key=self.key)
        mock_body.close.assert_called_once()

    @patch('boto3.client')
    def test_file_not_found(self, mock_boto3_client):
        """
        Test handling of file not found error.
        Demonstrates mocking AWS-specific exceptions.
        """
        mock_s3 = Mock()
        
        # side_effect is used when you want the mock to do something other than return a value
        # It can raise an exception or return different values on subsequent calls
        # Here we're simulating an AWS ClientError for a missing file
        error_response = {'Error': {'Code': 'NoSuchKey'}}
        mock_s3.get_object.side_effect = ClientError(error_response, 'GetObject')
        mock_boto3_client.return_value = mock_s3

        with S3Reader(self.bucket) as reader:
            content = reader.read_file(self.key)

        # Verify that:
        # 1. None is returned for missing files (our expected behavior)
        # 2. The get_object call was made with correct parameters
        self.assertIsNone(content)
        mock_s3.get_object.assert_called_once_with(Bucket=self.bucket, Key=self.key)

    @patch('boto3.client')
    def test_retry_on_client_error(self, mock_boto3_client):
        """
        Test retry behavior on temporary client error.
        Demonstrates using side_effect to return different values on subsequent calls.
        """
        mock_s3 = Mock()
        error_response = {'Error': {'Code': 'SlowDown'}}
        
        # side_effect can take a list - each call will return/raise the next item
        # Here we simulate:
        # 1st call: Fails with SlowDown
        # 2nd call: Fails with SlowDown
        # 3rd call: Succeeds and returns content
        mock_s3.get_object.side_effect = [
            ClientError(error_response, 'GetObject'),  # First call fails
            ClientError(error_response, 'GetObject'),  # Second call fails
            {'Body': Mock(read=lambda: self.test_content)}  # Third call succeeds
        ]
        mock_boto3_client.return_value = mock_s3

        with S3Reader(self.bucket) as reader:
            content = reader.read_file(self.key)

        # Verify that:
        # 1. We eventually got the content
        # 2. It took exactly 3 attempts (2 failures + 1 success)
        self.assertEqual(content, self.test_content)
        self.assertEqual(mock_s3.get_object.call_count, 3)

    @patch('boto3.client')
    def test_unexpected_exception(self, mock_boto3_client):
        """
        Test handling of unexpected exceptions.
        Demonstrates testing error conditions and using assertRaises.
        """
        mock_s3 = Mock()
        # Here we simulate an unexpected error that should not be retried
        mock_s3.get_object.side_effect = ValueError("Unexpected error")
        mock_boto3_client.return_value = mock_s3

        # assertRaises is a context manager that verifies an exception is raised
        # The test passes only if the specified exception type is raised
        with self.assertRaises(ValueError):
            with S3Reader(self.bucket) as reader:
                reader.read_file(self.key)

if __name__ == '__main__':
    unittest.main()