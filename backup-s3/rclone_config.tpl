[scaleway]
type = s3
provider = Rclone
access_key_id = ${SCW_ACCESS_KEY_ID}
secret_access_key = ${SCW_SECRET_ACCESS_KEY}
region = other-v2-signature
endpoint = https://s3.fr-par.scw.cloud
location_constraint = fr-par

[clevercloud]
type = s3
provider = Other
access_key_id = ${CC_ACCESS_KEY_ID}
secret_access_key = ${CC_SECRET_ACCESS_KEY}
region = other-v2-signature
endpoint = https://cellar-c2.services.clever-cloud.com