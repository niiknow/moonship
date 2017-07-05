aws_auth = require "moonship.awsauth"

describe "moonship.awsauth", ->

  it "correctly generate signature", ->
    expected = {
      "Authorization": "AWS4-HMAC-SHA256 Credential=aws_access_key_id/20170703/aws_region/s3/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=b66e84e3d7efd07fa5c4337340d9069ae8fef3fd2792230fa93fcfbffb7e0346",
      "Content-Type": "application/x-www-form-urlencoded",
      "x-amz-content-sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "x-amz-date": "20170703T155448Z"
    }
    opts = {
        aws_region: "aws_region",
        aws_access_key_id: "aws_access_key_id",
        aws_secret_access_key: "aws_secret_access_key",
        aws_s3_code_path: "aws_s3_code_path",
        timestamp: 1499097288
    }
    actual = aws_auth.AwsAuth(opts)\get_auth_headers()

    assert.same expected, actual
