{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pike";
  version = "0.3.91";

  src = fetchFromGitHub {
    owner = "jameswoolfenden";
    repo = "pike";
    rev = "v${version}";
    hash = "sha256-PMA/4fmAE5pc6aeCYm0yfbLy2IJnOI7JJFvnmKhxZH4=";
  };

  vendorHash = "sha256-1V8LODOmRO4Y9z+UCi+DGT96LY1F8bOUMMCNzbk9AgI=";

  # Tests require Terraform installation
  doCheck = false;

  meta = {
    description = "Generate IAM policies from Terraform/CloudFormation";
    homepage = "https://github.com/jameswoolfenden/pike";
  };
}
