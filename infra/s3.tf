resource "aws_s3_bucket" "artifact_store" {
    bucket = "s3-bucket-java-app-${var.environment}"
    force_destroy = true
    lifecycle {
        prevent_destroy = false
    }

    tags = merge(
            { 
                "Name" = "s3-bucket-java-app-${var.environment}"
            },
            var.common_tags
    )
}

resource "aws_s3_bucket_ownership_controls" "example" {
    bucket = aws_s3_bucket.artifact_store.id
    rule {
        object_ownership = "BucketOwnerEnforced"
    }
}
