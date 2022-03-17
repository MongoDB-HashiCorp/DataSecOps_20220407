import sys
import base64
import hvac
from pymongo import MongoClient
import datetime

def base64ify(bytes_or_str):
  if sys.version_info[0] >= 3 and isinstance(bytes_or_str, str):
    input_bytes = bytes_or_str.encode('utf8')
  else:
    input_bytes = bytes_or_str

  output_bytes = base64.urlsafe_b64encode(input_bytes)
  if sys.version_info[0] >= 3:
    return output_bytes.decode('ascii')
  else:
    return output_bytes

str_url   = "https://gs-cluster.vault.50dc8a23-a8c8-4982-8053-6ba3cf2f254f.aws.hashicorp.cloud:8200"
str_token = "s.Zxf7WduhMaxmob5L2zxYWoCd.B4qAX"
vault_client = hvac.Client(
  url=str_url,
  token=str_token,
  namespace="admin"
)

read_response = vault_client.secrets.kv.read_secret_version(path='atlas-info')
print(f'atlas-info secret kv private : {read_response["data"]["data"]["private_srv"]}')
print(f'atlas-info secret kv public  : {read_response["data"]["data"]["public_srv"]}\n')

mongodb_URI = read_response["data"]["data"]["public_srv"]
mongodb_client = MongoClient(mongodb_URI)

# Create DB
mydb = mongodb_client["mydb"]
mycol = mydb["customers"]


# Data
email = "contact-kr@hashicorp.com"
print(f'original data : {email}')

encrypt_data_response = vault_client.secrets.transit.encrypt_data(
    name='my-key',
    plaintext=base64ify(email.encode()),
)
ciphertext = encrypt_data_response['data']['ciphertext']
print(f'encrypted data : {ciphertext}')

post = {
  "author": "GS",
  "text": "Let's DataSecOps with MongoDB Atlas & HashiCorp!",
  "email": ciphertext,
  "tags": ["mongodb", "hashicorp"],
  "date": datetime.datetime.utcnow()
}

post_id = mycol.insert_one(post).inserted_id
print(f'insert id : {post_id}')

find_post = mycol.find_one({"_id": post_id})
print(find_post)

decrypt_data_response = vault_client.secrets.transit.decrypt_data(
    name='my-key',
    ciphertext=find_post['email'],
)
plaintext = decrypt_data_response['data']['plaintext']
print(f'decrypt data : {base64.urlsafe_b64decode(plaintext)}')