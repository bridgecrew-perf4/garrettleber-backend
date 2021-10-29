resource "aws_codepipeline" "frontend_deploy" {
  name     = "garrettleber-s3-deploy"
  role_arn = "arn:aws:iam::327910803467:role/service-role/AWSCodePipelineServiceRole-us-east-1-garrettleber-s3-deploy"

  artifact_store {
    location = aws_s3_bucket.website_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.frontend_deploy.arn
        FullRepositoryId     = "lebergarrett/garrettleber-frontend"
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      namespace        = "DeployVariables"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = []

      configuration = {
        BucketName = aws_s3_bucket.website_bucket.id
        Extract    = "true"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "frontend_deploy" {
  name          = "lebergarrett-github-connection"
  provider_type = "GitHub"
}