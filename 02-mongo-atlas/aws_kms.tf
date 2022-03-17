// resource "aws_iam_role" "mongo" {
//   name = "atlas-kms-role"

//   assume_role_policy = <<EOF
// {
//   "Version": "2012-10-17",
//   "Statement": [
//     {
//       "Effect": "Allow",
//       "Principal": {
//         "AWS": "arn:aws:iam::536727724300:root"
//       },
//       "Action": "sts:AssumeRole",
//       "Condition": {
//         "StringEquals": {
//           "sts:ExternalId": "${mongodbatlas_cloud_provider_access_setup.setup_only.aws.atlas_assumed_role_external_id}"
//         }
//       }
//     }
//   ]
// }
// EOF
// }

// resource "aws_kms_grant" "mongo" {
//   name              = "mongo-grant"
//   key_id            = data.terraform_remote_state.infra.outputs.kms_id
//   grantee_principal = aws_iam_role.mongo.arn
//   operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
// }